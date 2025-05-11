{ ... }:
{
  # TODO gate behind server/desktop/laptop "feature" group?
  config = {
    services.libinput = {
      enable = true;
      mouse = {
        accelProfile = "adaptive";
        accelSpeed = "+0.5";
      };
      touchpad = {
        clickMethod = "clickfinger";
        tapping = true;
        scrollMethod = "twofinger";
        horizontalScrolling = true;
        naturalScrolling = false;
        disableWhileTyping = true;
        accelProfile = "adaptive";
        accelSpeed = "+0.5";
      };
    };
  };
}
