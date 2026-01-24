{
  lib,
  symlinkJoin,
  makeBinaryWrapper,
  writers,
  update-modrinth-lock-unwrapped,
  nixosConfigs,
}:
let
  src = update-modrinth-lock-unwrapped;

  mods = lib.pipe nixosConfigs [
    # Collect all configured servers
    (map (nixos: nixos.config.services.minecraft-servers.servers or { }))
    (lib.concatMap lib.attrValues)

    # Collect all configured mod derivations
    (lib.catAttrs "mods")
    (lib.concatMap lib.attrValues)

    # Collect Modrinth version IDs
    (lib.filter (drv: drv.modrinth or false))
    (lib.catAttrs "versionId")

    # De-duplicate
    (lib.flip lib.genAttrs (_: null))
    lib.attrNames
  ];
in

symlinkJoin {
  name = src.name + "-wrapped";
  exe = src.meta.mainProgram;
  paths = [ src ];
  nativeBuildInputs = [ makeBinaryWrapper ];
  modsJson = writers.writeJSON "version-ids-json" mods;
  postBuild = ''
    wrapProgram "$out/bin/$exe" --add-flags "--mods-file $modsJson"
  '';
  passthru = src.passthru // {
    inherit mods;
  };
  inherit (src) meta;
}
