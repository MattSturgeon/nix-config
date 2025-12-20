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

      extraPackages =
        epkgs: with epkgs; [
          catppuccin-theme
          # 2025-12-20: tree-sitter-razor is marked as broken
          # treesit-grammars.with-all-grammars
        ];

      extraConfig = # lisp
        ''
          ;;; For performance, increase GC threshold during init
          (setq gc-cons-threshold 100000000)
          (setq read-process-output-max (* 1024 1024)) ;; 1mb

          ;;; Restore normal GC after init
          (add-hook 'after-init-hook #'(lambda () (setq gc-cons-threshold 800000)))

          ;;; Disable menu-bar, tool-bar, and scroll-bar.
          (if (fboundp 'menu-bar-mode)
              (menu-bar-mode -1))
          (if (fboundp 'tool-bar-mode)
              (tool-bar-mode -1))
          (if (fboundp 'scroll-bar-mode)
              (scroll-bar-mode -1))

          ;;; Colorscheme
          (setq catppuccin-flavor 'mocha)
          (load-theme 'catppuccin :no-confirm)
        '';
    };

    services.emacs = {
      # Emacs daemon
      # `package` will default to `programs.emacs.package`
      enable = true;

      # Start daemon when the client runs
      socketActivation.enable = true;
      # extraOptions = [ ];
    };
  };
}
