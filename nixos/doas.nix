{ config, pkgs, ... }: {

    security.doas.enable = true;
    security.sudo.enable = false;

    security.doas.extraRules = [{
        groups = [ "wheel" ];
        keepEnv = true;
        persist = true;  
	noPass = false;
    }];

}
