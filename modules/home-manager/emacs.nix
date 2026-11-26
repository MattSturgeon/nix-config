{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.editors;

  # Doom Emacs dependencies
  # https://github.com/doomemacs/doomemacs/blob/master/docs/getting_started.org#nixos
  doomDependencies = with pkgs; [
    git
    ripgrep
    coreutils
    fd
    clang
  ];

  doomVars = {
    emacs = "${config.xdg.configHome}/emacs";
    config = "${config.xdg.configHome}/doom";
    pathPrefix = lib.makeBinPath ([ config.programs.emacs.package ] ++ doomDependencies);
  };
in
{
  options.custom.editors.emacs = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Use Emacs";
  };

  config = lib.mkIf cfg.emacs {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
    };

    services.emacs = {
      # Emacs daemon
      # `package` will default to `programs.emacs.package`
      enable = true;

      # Start daemon when the client runs
      socketActivation.enable = true;
      # extraOptions = [ ];
    };

    home.packages = doomDependencies;

    home.activation.setupDoomEmacs =
      lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" "cleanUp" ]
        /* bash */ ''
          setupDoomEmacs() {
            log() {
              echo "setupDoomEmacs: $*" >&2
            }

            local ${toString (lib.attrNames doomVars)}
            ${lib.toShellVars doomVars}

            # Activation has a minimal PATH, so temporarily add Doom's dependencies
            local -x PATH="$pathPrefix:$PATH"

            if [ -d "$emacs" ]; then
              # Assert Doom Emacs is installed
              [ -f "$emacs"/bin/doom ] || {
                log "Skipping Doom Emacs installation, another Emacs config exists at $emacs"
                return
              }
            else
              # Install Doom Emacs
              ${lib.getExe pkgs.gitMinimal} clone --depth 1 https://github.com/doomemacs/doomemacs "$emacs"
              yes | "$emacs"/bin/doom install
            fi


            # TODO: symlink mutable config to ~/.config/doom
            # Or clone a config repo, managed separately from this repo?
            if [ ! -d "$config" ]; then
              log "No Doom Emacs config found"
            fi

            # Sync
            "$emacs"/bin/doom sync

          }
          setupDoomEmacs
        '';

    home.sessionPath = [
      "${config.xdg.configHome}/emacs/bin"
    ];
  };
}
