{ config, pkgs, ... }: {

    programs.fish = {
	enable = true;
	interactiveShellInit = ''
	    set fish_greeting # Disable the greeting
	'';
    };
}
