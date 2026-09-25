{
  perSystem =
    { pkgs, ... }:
    {
      packages = {
        minecraft-archive = pkgs.callPackage ./minecraft-archive { };
        quad-modpack = pkgs.callPackage ./quad-modpack { };
        yaemoji-idea-plugin = pkgs.callPackage ./yaemoji-idea-plugin { };
      };
    };
}
