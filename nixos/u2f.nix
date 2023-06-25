{ config, pkgs, ... }: {

    # It is no longer required to enable hardware.u2f, udev has native support.

    # Allow u2f to be used for login/sudo
    # Add a key to `~/.config/Yubico/u2f_keys`
    # to trust a Yubikey:
    # nix-shell -p pam_u2f pamu2fcfg >> ~/.config/Yubico/u2f_keys
    security.pam.services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
    };

}