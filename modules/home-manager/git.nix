{ ... }:
{
  # TODO get name, email, & key from config or user
  config = {
    programs.git = {
      enable = true;
      signing = {
        key = "ED1A8299";
        signByDefault = true;
      };
      settings = {
        user.name = "Matt Sturgeon";
        user.email = "matt@sturgeon.me.uk";
        init.defaultBranch = "main";
        pull.ff = true;
        pull.rebase = true;
        rebase.autosquash = true;
        help.autoCorrect = "prompt";
      };
    };

    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };

    programs.lazygit = {
      enable = true;
      settings = { };
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
