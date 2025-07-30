{
  lib,
  mkShell,
  nix,
  home-manager,
  git,
  formatter ? null,
}:
mkShell {
  # Enable experimental features without having to specify the argument
  env.NIX_CONFIG = "experimental-features = nix-command flakes";

  nativeBuildInputs = [
    nix
    home-manager
    git
  ]
  ++ lib.optionals (formatter != null) [
    formatter
  ];
}
