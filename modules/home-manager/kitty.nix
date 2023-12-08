{...}: {
  config = {
    programs.kitty = {
      enable = true;

      # Enable shell completions (etc) for kitty command
      shellIntegration.enableBashIntegration = true;
      shellIntegration.enableFishIntegration = true;

      # TODO define theme somewhere in config
      theme = "Catppuccin-Mocha";

      keybindings = {
        "ctrl+c" = "copy_and_clear_or_interrupt";
        "ctrl+shift+c" = "copy_to_clipboard";
      };

      settings = {
        # Force fish even when login shell is different
        shell = "fish";
        # system, background, #hex, or color name
        wayland_titlebar_color = "background";
      };

      # TODO use fonts defined in nix config
      font = {
        name = "Jetbrains Mono";
        size = 12;
      };

      # TODO use fonts defined in nix config
      extraConfig = ''
        # Emoji font
        symbol_map U+1F600-U+1F64F Noto Color Emoji

        # Fallback to Nerd Font Symbols
        symbol_map U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6AA,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F4A9,U+F500-U+F8FF,U+F0001-U+F1AF0 Symbols Nerd Font Mono
      '';
    };
  };
}
