{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.editors;
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
      package = pkgs.emacs-pgtk.overrideAttrs (prevAttrs: {
        patches = prevAttrs.patches or [ ] ++ [
          (pkgs.fetchpatch {
            name = "Automatically-toggle-between-dark-and-light-mode-PGTK-widgets.patch";
            url = "https://cgit.git.savannah.gnu.org/cgit/emacs.git/patch/?id=dd9d1df4fa6c96acecaae94461d962da1d822494";
            hash = "sha256-Z4PfdPlEXm0Q3VltyUT2BOxmhXM3nUTbstfuwFvmuhU=";
            excludes = [ "etc/NEWS" ];
          })
        ];
      });
    };

    services.emacs = {
      # Emacs daemon
      # `package` will default to `programs.emacs.package`
      enable = true;

      # Start daemon when the client runs
      socketActivation.enable = true;
      # extraOptions = [ ];
    };

    home.packages = with pkgs; [
      # Doom Emacs dependencies
      # https://github.com/doomemacs/doomemacs/blob/master/docs/getting_started.org#nixos
      git
      ripgrep
      coreutils
      fd
      clang
    ];

    home.activation.setupDoomEmacs =
      lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" "cleanUp" ]
        /* bash */ ''
          setupDoomEmacs() {
            log() {
              echo "setupDoomEmacs: $*" >&2
            }
            local ${lib.toShellVar "emacs" "${config.xdg.configHome}/emacs"}
            local ${lib.toShellVar "config" "${config.xdg.configHome}/doom"}

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
