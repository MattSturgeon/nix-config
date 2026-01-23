{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  buildIdeWithPlugins = inputs.nix-jetbrains-plugins.lib.buildIdeWithPlugins pkgs;

  cfg = config.custom.editors.idea;

  idea = buildIdeWithPlugins "idea" (lib.attrValues cfg.plugins);

  # NOTE: the jetbrains packages already do similar wrapping internally.
  ideaWrapped = pkgs.symlinkJoin {
    inherit (idea)
      pname
      version
      meta
      passthru
      ;
    nativeBuildInputs = with pkgs; [
      makeBinaryWrapper
    ];
    paths = [ idea ];
    ide = idea;
    rootDir = idea.meta.mainProgram;
    libraryPath = lib.makeLibraryPath cfg.extraLibs;
    postBuild = ''
      for exe in "$out/$rootDir"/bin/*
      do
        [ -x "$exe" ] || continue

        if ( file "$exe" | grep -q 'text' ); then
          substitute "$exe" tmp.out --replace-quiet "$ide" "$out"
          mv --force tmp.out "$exe"
        fi

        wrapProgram "$exe" \
          --prefix LD_LIBRARY_PATH : "$libraryPath"
      done
    '';
  };

  jetbrainsPluginIdType = lib.types.str // {
    description = "Jetbrains plugin ID";
    descriptionClass = "noun";
  };
in
{
  options.custom.editors.idea = {
    enable = mkEnableOption "Enable Intellij IDEA";
    plugins = lib.mkOption {
      type = lib.types.attrsOf jetbrainsPluginIdType;
      default = { };
      description = "Plugins to include with Intellij IDEA.";
    };
    extraLibs = lib.mkOption {
      type = with lib.types; listOf path;
      default = [ ];
      description = "Extra paths or packages to include on idea's `LD_LIBRARY_PATH`.";
    };
  };

  config = {
    home.packages = mkIf cfg.enable [
      ideaWrapped
    ];

    custom.editors.idea.plugins = {
      ideavim = "IdeaVIM";
      yet-another-emoji-support = "com.github.shiraji.yaemoji";
      dot-ignore = "mobi.hsz.idea.gitignore";
      minecraft-dev = "com.demonwav.minecraft-dev";
      minecraft-architectury = "me.shedaniel.architectury";
      minecraft-stonecutter = "dev.kikugie.stonecutter";
    };

    # Needed to launch Minecraft in Intellij
    # Based on `pkgs.prismlauncher`
    custom.editors.idea.extraLibs = with pkgs; [
      addDriverRunpath.driverLink

      flite # text to speach
      libusb1 # controller support

      ## native versions
      glfw3-minecraft
      openal

      ## openal
      alsa-lib
      libjack2
      libpulseaudio
      pipewire

      ## glfw
      libGL
      xorg.libX11
      xorg.libXcursor
      xorg.libXext
      xorg.libXrandr
      xorg.libXxf86vm

      udev # oshi

      vulkan-loader # VulkanMod's lwjgl
    ];
  };
}
