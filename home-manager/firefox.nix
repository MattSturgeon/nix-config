{ config, pkgs, ... }:

{
  programs = {
    firefox = {
      enable = true;
      profiles.matt = {
	id = 0;
	name = "Matt Sturgeon";
	isDefault = true;
	search = {
	  default = "google"; # TODO Move to something more privacy respecting?
	  force = true; # Firefox often replaces the symlink, so force on update
	};
        # extensions = [ ]; # (some are packaged in NUR)
	# extraConfig = '' ''; # user.js
	# userChrome = '' ''; # chrome CSS
	# userContent = '' ''; # content CSS
      };
    };
  };
}
