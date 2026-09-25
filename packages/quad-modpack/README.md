# Quad world modpack

This directory manages mods installed on `desktop`'s 'Quad' Minecraft server, using [Packwiz](https://github.com/packwiz/packwiz).

[`default.nix`](./default.nix) provides a link-farm containing all files in the modpack, fetched from the pinned URLs+hashes. It can be built using `nix build .#quad-modpack`.

To update mods, run:
```console
packwiz update --all
```

To migrate to a new Minecraft version, run:
```console
packwiz migrate minecraft [version]
```

You can also add or remove mods using `packwiz modrinth add [mod-slug]` and `packwiz remove [mod-slug]`, respectively.
See `packwiz --help` or the [online reference](https://packwiz.infra.link/reference/commands/packwiz/) for more detail.
