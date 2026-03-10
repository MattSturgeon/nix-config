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
from tqdm import tqdm

TIMESTAMP_FORMAT = "%Y-%m-%d--%H-%M-%S"


class ProgressFile:
    """Wrap a file object to update a progress bar when read"""

    def __init__(self, fileobj, progress: tqdm):
        self.fileobj = fileobj
        self.progress = progress

    def read(self, size=-1):
        data = self.fileobj.read(size)
        self.progress.update(len(data))
        return data


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


def compute_total_size(root: Path) -> int:
    """Compute total size of all files under a directory tree"""
    total = 0
    for dirpath, _, filenames in os.walk(root):
        for fname in filenames:
            fpath = Path(dirpath) / fname
            if fpath.is_file():
                try:
                    total += fpath.stat().st_size
                except PermissionError:
                    print(
                        f"skipping unreadable file for size: {fpath}", file=sys.stderr
                    )
    return total


def add_tree_with_progress(
    tar,
    root: Path,
    arc_root: str | None,
    level_dat: Path | None,
    enable_commands: bool,
    progress: tqdm,
) -> None:
    """Add a directory tree to a tarfile, updating tqdm"""

    def get_tarinfo(path: Path):
        rel = path.relative_to(root)
        if arc_root:
            rel = Path(arc_root) / rel
        return tar.gettarinfo(str(path), str(rel))

    for dirpath, _, filenames in os.walk(root):
        # Write the directory node
        dirpath = Path(dirpath)
        tar.addfile(get_tarinfo(dirpath))

        # Write each file
        for fname in filenames:
            fpath = dirpath / fname
            tarinfo = get_tarinfo(fpath)
            try:
                if enable_commands and level_dat and fpath == level_dat:
                    with patch_level_dat(fpath, allow_commands=True) as patched:
                        tarinfo.size = len(patched.getbuffer())
                        pf = ProgressFile(patched, progress)
                        tar.addfile(tarinfo, pf)
                else:
                    with fpath.open("rb") as f:
                        pf = ProgressFile(f, progress)
                        tar.addfile(tarinfo, pf)
            except PermissionError:
                tqdm.write(f"skipping unreadable file: {fpath}")


def create_archive(
    dest: Path,
    root: Path,
    arc_root: str,
    level_dat: Path,
    enable_commands: bool,
    progress: tqdm,
) -> Path:
    ts = datetime.datetime.now().strftime(TIMESTAMP_FORMAT)
    archive_path = dest / f"{root.name}-{ts}.tar.gz"

    if archive_path.exists():
        raise FileExistsError(f"{archive_path} already exists")

    with tarfile.open(archive_path, "w:gz") as tar:
        add_tree_with_progress(
            tar,
            root,
            arc_root,
            level_dat,
            enable_commands,
            progress,
        )

    return archive_path


def archive_one(
    servers_dir: Path,
    server: str,
    output: Path,
    scope: str,
    enable_commands: bool,
    position: int,
) -> Path | Exception:
    try:
        server_root = servers_dir / server
        world_name = get_world_name(server_root)
        if scope == "server":
            root = server_root
            arc_root = ""
            level_dat_path = server_root / world_name / "level.dat"
        elif scope == "world":
            root = server_root / world_name
            arc_root = world_name
            level_dat_path = root / "level.dat"
        else:
            raise ValueError(f"Unknown scope {scope}")

        with tqdm(
            total=compute_total_size(root),
            unit="B",
            unit_scale=True,
            desc=server,
            position=position,
            leave=True,
        ) as progress:
            return create_archive(
                output,
                root,
                arc_root,
                level_dat_path,
                enable_commands,
                progress,
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
                server,
                args.output,
                args.scope,
                args.enable_commands,
                idx,
            ): server
            for idx, server in enumerate(servers)
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
