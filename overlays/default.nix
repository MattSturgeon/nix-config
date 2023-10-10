# This file defines overlays
# https://nixos.wiki/wiki/Overlays
{...}: {
  # Overlay custom packages into pkgs
  additions = final: prev:
    import ../pkgs {
      pkgs = prev;
    };
}
