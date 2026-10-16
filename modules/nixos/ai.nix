{ pkgs, ... }:
{
  config = {
    services.ollama.enable = true;

    environment.systemPackages = [
      pkgs.opencode
    ];
  };
}
