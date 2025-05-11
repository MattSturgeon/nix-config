{ ... }:
{
  config = {
    # home-manager needs to manage bash in order for sessionVariables
    # to be added to ~/.profile
    programs.bash.enable = true;

    # Enable fish shell
    programs.fish = {
      enable = true;
      interactiveShellInit = # fish
        ''
          set fish_greeting # Disable the greeting
        '';
    };

    # Use the starship prompt
    programs.starship = {
      enable = true;
      enableTransience = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      # See https://starship.rs/config
      settings = {
        add_newline = true;
        character = {
          success_symbol = "➜(bold green)";
          error_symbol = "➜(bold red)";
        };
      };
    };

    # Define the transient prompt
    programs.fish.functions = {
      starship_transient_prompt_func = # fish
        ''
          if fish_is_root_user
              echo '# '
          else
              echo '$ '
          end
        '';
    };
  };
}
