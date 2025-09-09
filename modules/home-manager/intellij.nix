{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  idea-plugins = [
    "ideavim"
  ];

  cfg = config.custom.editors;

  idea = with pkgs.jetbrains; plugins.addPlugins idea-community-bin idea-plugins;

  # NOTE: the jetbrains packages already do similar wrapping internally.
  # TODO: make it easier to extend `extraLdPath` and other arguments via overrides,
  # e.g. by using a finalAttrs-style derivation.
  ideaWrapped =
    pkgs.runCommand idea.name
      {
        env.ide = idea;
        env.roodDir = idea.meta.mainProgram;

        nativeBuildInputs = with pkgs; [
          makeWrapper
        ];

        inherit (idea) meta passthru;
      }
      ''
        cp -r "$ide" "$out"
        chmod +w -R "$out"

        (
          shopt -s nullglob

          for exe in "$out/$rootDir"/bin/*
          do
            if [ -x "$exe" ] && ( file "$exe" | grep -q 'text' )
            then
              substituteInPlace "$exe" --replace-quiet "$ide" "$out"
            fi
            wrapProgram "$exe" \
              --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath cfg.extraIdeaLibs}
          done
        )
      '';
in
{
  options.custom.editors = {
    idea = mkEnableOption "Enable Intellij IDEA";
    extraIdeaLibs = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = "Extra packages to include on idea's `LD_LIBRARY_PATH`.";
    };
  };

  config = {
    home.packages = mkIf cfg.idea [
      ideaWrapped
    ];

    # Needed to launch Minecraft in Intellij
    custom.editors.extraIdeaLibs = with pkgs; [
      flite
      glfw-wayland-minecraft
      libGL
      libpulseaudio
      libusb1
      udev
    ];
  };
}
