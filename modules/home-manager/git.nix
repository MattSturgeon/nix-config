{ config
, ...
}:
let
  user = config.custom.user;
in
{
  # TODO get name, email, & key from config or user
  config = {
    programs.git = {
      enable = true;
      userName = user.description;
      userEmail = user.email;
      signing = {
        key = "ED1A8299";
        signByDefault = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        pull.ff = true;
        pull.rebase = true;
        rebase.autosquash = true;
        help.autoCorrect = "prompt";
      };
      delta.enable = true;
    };

    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };

    programs.lazygit = {
      enable = true;
      settings = { };
    };
  };
}
