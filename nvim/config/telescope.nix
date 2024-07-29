{
  plugins.telescope = {
    enable = true;
    # Keymaps defined in ./keymaps.nix

    extensions = {
      fzf-native.enable = true;
      media-files.enable = true;
    };
  };
}
