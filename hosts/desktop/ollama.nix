{ lib, pkgs, ... }:
{
  services.ollama = {
    enable = true;

    # Use ROCm for GPU acceleration
    package = pkgs.ollama-rocm;

    # Expose ollama to the network.
    host = "0.0.0.0";
    openFirewall = true;

    # TODO: do I need this at all? Pulling and creating models imperatively isn't so bad.
    # Pull these models on boot
    # See: https://ollama.com/library
    loadModels = [
      "qwen2.5-coder:14b"
      "deepseek-coder-v2:16b"

      # Do I need these smaller models for anything? Maybe for big context problems? But then, wouldn't a small model struggle with such problems?
      "deepseek-coder:1.3b"
      "deepseek-coder:6.7b"

      # Do I need these larger models for anything? They will fit in VRAM only without context...
      "qwen3.8:27b"
      "gemma4:26b"
      "gemma4:31b"
    ];

    # Keep model storage on the larger disk, independently of root impermanence.
    home = "/srv/ollama";

    # Which requires a persistent user
    user = "ollama";
    group = "ollama";
  };

  # TODO: consider running `ollama create qwen3-opencode --file Modelfile` setup in a systemd oneshot??
  # Otherwise I haven models but not a 'model config' with enough context

  # Workaround for persistent user:
  # https://github.com/NixOS/nixpkgs/issues/357604
  systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

  # Give ollama access to its home
  systemd.tmpfiles.rules = [
    "d /srv/ollama 0750 ollama ollama -"
  ];
}
