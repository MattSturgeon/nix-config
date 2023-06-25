{ config, pkgs, ... }: {

    programs.vscode = {
	enable = true;
	enableUpdateCheck = false;
	enableExtensionUpdateCheck = false;

	userSettings = {
	    # UI
	    "window.titleBarStyle" = "custom"; # native or custom
	    "window.menuBarVisibility" = "toggle"; # Hidden until hitting <Alt>
	    "workbench.sideBar.location" = "right";
	    "workbench.editor.closeOnFileDelete" = true;
	    "workbench.editor.enablePreview" = false;
	    "workbench.editor.untitled.hint" = "hidden";
	    "workbench.iconTheme" = "vs-minimal";
	    "workbench.startupEditor" = "none";
	    "workbench.statusBar.visible" = true;
	    "workbench.tips.enabled" = false;
	    "workbench.welcomePage.walkthroughs.openOnInstall" = false;
	    "window.zoomLevel" = -1; # Make everything more compact

	    "telemetry.telemetryLevel" = "off";

	    # Theme & font
	    "workbench.colorTheme" = "Catppuccin Mocha";
	    "editor.fontFamily" = "'JetBrains Mono', 'Symbols Nerd Font', 'Noto Color Emoji'";
	    "editor.fontSize" = 14;
	    "editor.fontLigatures" = true;

	    # Terminal
	    "terminal.external.linuxExec" = "kitty";
	    "terminal.integrated.defaultProfile.linux" = "fish";
	    "terminal.integrated.gpuAcceleration" = "on";
	    
	    # Vim
	    "vim.leader" = " ";
	    "editor.cursorSurroundingLines" = 8; # scrolloff
	    "vim.smartRelativeLine" = true;
	    "vim.hlsearch" = true;
	    "vim.highlightedyank.enable" = true;

	    "vim.insertModeKeyBindings" = [
	        { # jj to quickly exit insert mode
		    before = [ "j" "j" ];
		    after = [ "<Esc>" ];
		}
	    ];

	    "vim.normalModeKeyBindings" = [
	        { # Shift-K to show "hover" documentation
		    before = [ "K" ];
		    after = [ "g" "h" ];
		}
		{
		    before = [ "g" "i" ];
		    commands = [ "editor.action.goToImplementation" ];
		}
	    ];
	};
	extensions = with pkgs.vscode-extensions; [
	   catppuccin.catppuccin-vsc 
	   vscodevim.vim
	   github.codespaces
	   # ms-vscode-remote.remote-containers # Not in nixpkgs
	];
    };
}
