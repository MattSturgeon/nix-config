#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK

"""
mc-archive: Archive Minecraft server worlds.

- Lists available servers with --list-servers
- Archives a server to a timestamped tar.gz file
- Default server directory: /srv/minecraft
"""

import argcomplete
import argparse
import datetime
import nbtlib
import os
import sys
import tarfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from io import BytesIO
from pathlib import Path

TIMESTAMP_FORMAT = "%Y-%m-%d--%H-%M-%S"


def list_servers(servers_dir: Path) -> list[str]:
    """Return a sorted list of server directories containing server.properties."""
    if not servers_dir.is_dir():
        return []
    return sorted(
        p.name
        for p in servers_dir.iterdir()
        if p.is_dir() and (p / "server.properties").is_file()
    )


def get_world_name(server_dir: Path) -> str:
    """Read the server's world name from server.properties."""
    props = server_dir / "server.properties"
    if not props.is_file():
        return "world"

    with props.open() as f:
        for raw in f:
            line = raw.lstrip().rstrip("\r\n")
            if not line or line.startswith(("#", "!")):
                continue

            key, sep, value = line.partition("=")
            if sep and key.strip() == "level-name":
                return value.lstrip(" ")

    return "world"


def patch_level_dat(file: Path, allow_commands: bool) -> BytesIO:
    """Patch level.dat NBT file in-memory"""

    # Load into memory
    nbt = nbtlib.load(file)

    # Apply patches
    nbt["Data"]["allowCommands"] = nbtlib.Byte(1 if allow_commands else 0)

    # Serialize to bytes in memory
    buffer = BytesIO()
    nbt.save(buffer)
    buffer.seek(0)

    return buffer


def create_archive(
    servers_dir: Path,
    server: str,
    dest: Path,
    scope: str,
    enable_commands: bool,
) -> Path:
    src = servers_dir / server

    if not src.is_dir():
        raise FileNotFoundError(f"Server '{server}' not found in {servers_dir}")

    ts = datetime.datetime.now().strftime(TIMESTAMP_FORMAT)
    archive_path = dest / f"{server}-{ts}.tar.gz"

    if archive_path.exists():
        raise FileExistsError(f"{archive_path} already exists")

    world_name = get_world_name(src)
    world_path = src / world_name
    level_path = world_path / "level.dat"
    level_arcname = f"{world_name}/level.dat"

    def tar_filter(tarinfo):
        """Skip level.dat if we're patching it."""
        if enable_commands and tarinfo.name == level_arcname:
            return None
        return tarinfo

    # TODO: show progress while archiving
    with tarfile.open(archive_path, "w:gz") as tar:
        if scope == "server":
            tar.add(src, arcname="", filter=tar_filter)

        elif scope == "world":
            if not world_path.is_dir():
                raise FileNotFoundError(
                    f"Server '{server}' world directory not found: {world_path}"
                )
            tar.add(world_path, arcname=world_name, filter=tar_filter)

        else:
            raise ValueError(f"Unknown scope: {scope}")

        if enable_commands:
            if not level_path.is_file():
                raise FileNotFoundError(f"{level_path} not found")

            tar.addfile(
                tarinfo=tar.gettarinfo(
                    name=level_path,
                    arcname=level_arcname,
                ),
                fileobj=patch_level_dat(level_path, allow_commands=True),
            )

    return archive_path


def archive_one(
    servers_dir: Path,
    server: str,
    output: Path,
    scope: str,
    enable_commands: bool,
) -> Path | Exception:
    try:
        return create_archive(
            servers_dir,
            server,
            output,
            scope,
            enable_commands,
        )
    except Exception as e:
        return e


def positive_int(value: str) -> int:
    """argparse type representing a positive integer"""
    ivalue = int(value)
    if ivalue < 1:
        raise argparse.ArgumentTypeError("must be > 0")
    return ivalue


def servers_completer(prefix, parsed_args, **kwargs):
    """Adapts 'list_servers' as a completion provider for the 'servers' arg."""
    return list_servers(parsed_args.servers_dir)


def build_parser() -> argparse.ArgumentParser:
    """Create the CLI parser for minecraft-archive."""
    parser = argparse.ArgumentParser(
        description="Archive a snapshot of a Minecraft server on this system"
    )

    xgroup = parser.add_mutually_exclusive_group()

    xgroup.add_argument(
        "servers",
        metavar="server",
        nargs="*",
        help="Server(s) to archive",
    ).completer = servers_completer

    xgroup.add_argument(
        "--all",
        action="store_true",
        help="Archive all detected servers",
    )

    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=Path.cwd(),
        help="Destination directory",
    )

    parser.add_argument(
        "--servers",
        dest="servers_dir",
        type=Path,
        default=Path("/srv/minecraft"),
        metavar="dir",
        help="Minecraft servers directory",
    )

    parser.add_argument(
        "--scope",
        choices=["world", "server"],
        default="world",
        help="Archive scope",
    )

    parser.add_argument(
        "--op",
        "--enable-commands",
        dest="enable_commands",
        action="store_true",
        help="Modify level.dat to enable commands in the archive",
    )

    parser.add_argument(
        "-j",
        "--jobs",
        type=positive_int,
        default=1,
        metavar="N",
        help="Number of concurrent archives",
    )

    parser.add_argument(
        "--list-servers",
        action="store_true",
        help="Print available servers and exit",
    )

    if os.environ.get("_ARGCOMPLETE"):
        argcomplete.autocomplete(parser)

    return parser


def main() -> None:
    """Parse arguments and execute archive or server listing."""
    parser = build_parser()
    args = parser.parse_args()

    servers_dir = args.servers_dir

    if args.list_servers:
        for server in list_servers(servers_dir):
            print(server)
        return

    if args.all:
        servers = list_servers(servers_dir)
    else:
        servers = args.servers

    # Remove duplicates
    servers = list(dict.fromkeys(servers))

    if not servers:
        parser.error("no servers specified")

    jobs = min(args.jobs, len(servers))

    args.output.mkdir(parents=True, exist_ok=True)

    errors = False

    with ThreadPoolExecutor(max_workers=jobs) as pool:
        futures = {
            pool.submit(
                archive_one,
                servers_dir,
                s,
                args.output,
                args.scope,
                args.enable_commands,
            ): s
            for s in servers
        }

        try:
            for f in as_completed(futures):
                result = f.result()
                server = futures[f]

                if isinstance(result, Exception):
                    print(f"error: {server}: {result}", file=sys.stderr)
                    errors = True
                else:
                    print(f"Created archive: {result}")

        except KeyboardInterrupt:
            print("\nCancelling jobs...", file=sys.stderr)

            for f in futures:
                f.cancel()

            raise

    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
