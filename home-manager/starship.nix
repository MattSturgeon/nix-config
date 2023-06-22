{ config, pkgs, ... }: {

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

}
