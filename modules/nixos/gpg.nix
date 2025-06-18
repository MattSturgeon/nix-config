{
  # Since https://github.com/NixOS/nixpkgs/pull/379731
  # the new `services.gcr-ssh-agent` option is enabled by default when
  # `services.gnome.gnome-keyring` is enabled.
  #
  # This is incompatible with gpg-agent's ssh support,
  # which I configure from home-manager.
  services.gnome.gcr-ssh-agent.enable = false;
}
