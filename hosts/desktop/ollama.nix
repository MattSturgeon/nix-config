{ lib, pkgs, ... }:
{
  services.ollama = {
    enable = true;

    # Use ROCm for GPU acceleration
    package = pkgs.ollama-rocm;

    # Expose ollama to the network.
    host = "0.0.0.0";
    openFirewall = true;

    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };

    # Keep model storage on the larger disk, independently of root impermanence.
    home = "/srv/ollama";

    # Which requires a persistent user
    user = "ollama";
    group = "ollama";
  };

  # Workaround for persistent user:
  # https://github.com/NixOS/nixpkgs/issues/357604
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  # Give ollama access to its home
  systemd.tmpfiles.rules = [
    "d /srv/ollama 0750 ollama ollama -"
  ];
}
