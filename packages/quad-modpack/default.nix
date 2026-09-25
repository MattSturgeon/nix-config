{
  lib,
  fetchurl,
  linkFarm,
}:
# Implements a nix linkFarm, derived from Packwiz lockfiles
let
  pack = lib.importTOML ./pack.toml;
  index = lib.importTOML ./${pack.index.file};

  # Map Packwiz server-side files to linkFarm entries
  packFiles = lib.concatMap (
    info:
    let
      # Relative filepath: e.g., "mods/appleskin.pw.toml"
      inherit (info) file;
    in
    if info.metafile or false then
      # Resolve file from its Packwiz metafile
      let
        meta = lib.importTOML ./${file};
        directory = dirOf file;
        targetFile = lib.optionalString (directory != "") (directory + "/") + meta.filename;
        isServerSide = meta.side or "both" != "client";
      in
      lib.optional isServerSide {
        name = targetFile;
        path = fetchurl {
          url = meta.download.url;
          ${meta.download.hash-format} = meta.download.hash;
        };
      }
    else
      # Transparently include local file
      lib.singleton {
        name = file;
        path = ./${file};
      }
  ) index.files;
in
(linkFarm "quad-modpack" packFiles).overrideAttrs (
  finalAttrs: prevAttrs: {
    passthru = prevAttrs.passthru or { } // {
      inherit pack index;
    };
  }
)
