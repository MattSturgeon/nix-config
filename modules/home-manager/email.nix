{ lib, ... }:
let
  fromHexString = s: if lib.isString s then lib.fromHexString s else s;
  setFlags = flags: lib.foldr (flag: lib.bitOr (fromHexString flag)) 0 (lib.toList flags);
in
{
  config = {
    # TODO: Move to a user-specific module
    accounts.email.accounts = {
      "matt@sturgeon.me.uk" = {
        address = "matt@sturgeon.me.uk";
        userName = "matt@sturgeon.me.uk";
        # TODO: passwordCommand
        realName = "Matt Sturgeon";
        signature.text = ''
          Kind regards,

          Matt Sturgeon
        '';
        imap = {
          host = "mail.privateemail.com";
          port = 993;
        };
        smtp = {
          host = "mail.privateemail.com";
          port = 465;
        };
        primary = true;
        thunderbird.enable = true;
      };
    };

    # TODO: Add custom options for choosing email client
    programs.thunderbird = {
      enable = true;

      profiles.default.isDefault = true;

      # See https://kb.mozillazine.org/Mail_and_news_settings
      settings = {
        # Disable the donations page popup and privacy rights
        "app.donation.eoy.url" = "";
        "mail.rights.version" = 1;

        # Start page
        "mailnews.start_page.enabled" = false;

        # Sort by
        # 18: Date
        "mailnews.default_sort_type" = 18;
        # 1: Ascending
        # 2: Descending
        "mailnews.default_sort_order" = 2;
        # Bit mask for default view of mail/RSS folders.
        # 0x0: None
        # 0x1 (default): Threaded display
        # 0x8: Show ignored
        # 0x10: Unread only
        # 0x20 Expand all
        # 0x40: Group by sort
        "mailnews.default_view_flags" = setFlags [ "1" ];

        # Data/Crash reporting
        "datareporting.healthreport.uploadEnabled" = true;
        "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
      };
    };
  };
}
