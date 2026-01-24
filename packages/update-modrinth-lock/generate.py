#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3

import argparse
import json
import sys
from pathlib import Path
from urllib.request import urlopen, Request
from urllib.error import HTTPError

from urllib.parse import quote, urljoin

MODRINTH_VERSION_API = "https://api.modrinth.com/v2/version/"


def fetch_version_info(version_id):
    """Fetch version info JSON from Modrinth API"""
    url = urljoin(MODRINTH_VERSION_API, quote(version_id, safe=""))
    req = Request(url, headers={"User-Agent": "modrinth-lockfile-generator"})
    try:
        with urlopen(req) as response:
            return json.load(response)
    except HTTPError as e:
        print(f"Error fetching version {version_id}: {e}", file=sys.stderr)
        return None


def select_primary_file(files):
    """Select the primary file or fallback to first"""
    for f in files:
        if f.get("primary"):
            return f
    return files[0] if files else None


def update_lockfile(mods, lockfile_path, full=False):
    """Update or generate the lockfile"""

    if isinstance(mods, dict):
        version_ids = mods.values()
    elif isinstance(mods, list):
        version_ids = mods
    else:
        raise TypeError("mods JSON must be an object or array")

    lockfile = {}
    if lockfile_path.exists() and not full:
        with lockfile_path.open() as f:
            lockfile = json.load(f)

    updated_lock = {}

    for version_id in version_ids:
        if not full and version_id in lockfile:
            print(f"Skipping {version_id} (cached)")
            updated_lock[version_id] = lockfile[version_id]
            continue

        info = fetch_version_info(version_id)
        if not info:
            print(f"Skipping {version_id} (fetch error)", file=sys.stderr)
            continue

        file_entry = select_primary_file(info.get("files", []))
        if not file_entry:
            print(f"No files found for {version_id}", file=sys.stderr)
            continue

        updated_lock[version_id] = {
            "url": file_entry["url"],
            "sha512": file_entry["hashes"]["sha512"],
        }
        print(f"Fetched {version_id}")

    with lockfile_path.open("w") as f:
        json.dump(updated_lock, f, indent=2, sort_keys=True)

    print(f"Lockfile written to {lockfile_path}")


def main():
    parser = argparse.ArgumentParser(description="Generate/update a modrinth.lock file")
    parser.add_argument("--mods-file", required=True, help="JSON file with mod_name -> version_id")
    parser.add_argument("--lockfile", default="modrinth.lock", help="Output lockfile path")
    parser.add_argument("--full", action="store_true", help="Rebuild all entries from scratch")
    args = parser.parse_args()

    mods_path = Path(args.mods_file)
    if not mods_path.exists():
        print(f"Mods file {mods_path} not found", file=sys.stderr)
        sys.exit(1)

    with mods_path.open() as f:
        mods = json.load(f)

    update_lockfile(mods, Path(args.lockfile), full=args.full)


if __name__ == "__main__":
    main()
