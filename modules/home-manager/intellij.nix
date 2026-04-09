{
  config,
  lib,
  pkgs,
  self,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (inputs.nix-jetbrains-plugins.lib) pluginsForIde;
  inherit (pkgs.stdenv.hostPlatform) system;

  yet-another-emoji-support =
    let
      id = "com.github.shiraji.yaemoji";
      inherit (pkgs.jetbrains) idea;
      plugins = inputs.nix-jetbrains-plugins.plugins.${system}.${idea.pname}.${idea.version};
    in
    if plugins ? id then
      lib.warn "idea ${idea.version} has a compatible ${id} plugin" id
    else
      self.packages.${system}.yaemoji-idea-plugin;

  cfg = config.custom.editors.idea;

  idea = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea (lib.attrValues cfg.plugins);

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

  jetbrainsPluginType =
    ide:
    let
      name = ide.product or ide.vmoptsIDE or ide.pname or ide.name;
      pluginIdType = lib.types.str // {
        description = "plugin ID";
        descriptionClass = "noun";
      };

      pluginType = lib.types.path // {
        description = "${name} plugin";
        descriptionClass = "noun";
      };

      coerceFn = id: (pluginsForIde pkgs ide [ id ]).${id};
    in
    lib.types.coercedTo pluginIdType coerceFn pluginType;
in
{
  options.custom.editors.idea = {
    enable = mkEnableOption "Enable Intellij IDEA";
    plugins = lib.mkOption {
      type = lib.types.attrsOf (jetbrainsPluginType pkgs.jetbrains.idea);
      default = { };
      description = "Plugins to include with Intellij IDEA.";
    };
    extraLibs = lib.mkOption {
      type = with lib.types; listOf path;
      default = [ ];
      description = "Extra paths or packages to include on idea's `LD_LIBRARY_PATH`.";
    };
    vimrc = lib.mkOption {
      type = lib.types.submodule (
        { config, options, ... }:
        {
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              description = "Whether to install ideavimrc.";
              default = options.source.isDefined;
              defaultText = lib.literalMD "whether `${options.source}` is defined";
            };
            text = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              description = "Text to write to ideavimrc.";
            };
            source = lib.mkOption {
              type = lib.types.path;
              description = "File to install as ideavimrc.";
            };
            mutable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = ''
                When enabled, ideavimrc is installed as a regular (mutable) file instead of a symlink into the Nix store.

                Disabling this option later does not remove the existing file.

                If a different ideavimrc already exists during activation, it is backed up with the activation date.
              '';
            };
          };

          # Write `text` → `source` if non-null
          config.source = lib.mkIf (config.text != null) (
            lib.mkDerivedConfig options.text (pkgs.writeText "ideavimrc")
          );
        }
      );
      visible = "transparent";
      description = "Options for installing ideavimrc.";
      default = { };
    };
  };

  config = {
    home.packages = mkIf cfg.enable [
      ideaWrapped
    ];

    custom.editors.idea.plugins = {
      ideavim = "IdeaVIM";
      python = "PythonCore";
      inherit yet-another-emoji-support; # "com.github.shiraji.yaemoji"
      dot-ignore = "mobi.hsz.idea.gitignore";
      archive-browser = "com.github.b3er.idea.plugins.arc.browser";
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
      libx11
      libxcursor
      libxext
      libxrandr
      libxxf86vm

      udev # oshi

      vulkan-loader # VulkanMod's lwjgl
    ];

    # TODO: construct an ideavimrc influenced by nixvim config
    custom.editors.idea.vimrc.source = ../../nvim/ideavimrc;
    custom.editors.idea.vimrc.mutable = true;

    home.file.".ideavimrc" = lib.mkIf (cfg.vimrc.enable && !cfg.vimrc.mutable) {
      inherit (cfg.vimrc) source;
    };

    home.activation.installIdeavimrc = lib.mkIf (cfg.vimrc.enable && cfg.vimrc.mutable) (
      lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" "cleanUp" ] /* bash */ ''
        log() {
          echo "installIdeavimrc: $*" >&2
        }

        ${lib.toShellVar "source" "${cfg.vimrc.source}"}
        target="$HOME/.ideavimrc"

        if [ -e "$target" ]; then
          if cmp -s "$target" "$source"; then
            # Already up to date, nothing to do
            log "existing $target has not changed"
            exit 0
          fi

          # Find the latest backup
          latest_backup=
          for backup in "$target".[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].*; do
            [ -e "$backup" ] || continue
            latest_backup="$backup"
          done

          # Create a new backup
          if [ -n "$latest_backup" ] && cmp -s "$target" "$latest_backup"; then
            log "existing $target already has a valid backup: $latest_backup"
            log "view changes using: diff '$latest_backup' '$target'"
          else
            n=1
            date="$(date +%F)"
            while :; do
              backup="$target.$date.$n"
              [ -e "$backup" ] || break
              n=$((n + 1))
            done

            log "backing up $target → $backup"
            log "view changes using: diff '$backup' '$target'"
            mv "$target" "$backup"
          fi
        fi

        install -TDm644 "$source" "$target"
      ''
    );
  };
}
