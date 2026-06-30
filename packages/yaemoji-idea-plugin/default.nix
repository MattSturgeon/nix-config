{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gradle_9,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "yet-another-emoji-support";
  # Unreleased 1.1.4 with 2026.1 support
  version = "1.1.4-unstable-2026-04-29";

  src = fetchFromGitHub {
    owner = "shiraji";
    repo = "yet-another-emoji-support";
    rev = "c18afa0dc6b327ae703f7f27a24a39857580774e";
    hash = "sha256-s2EkDV/spE91uF1sHe+V9CXH58WsHZw1SGz8Z8r8x7Q=";
  };

  nativeBuildInputs = [
    gradle_9
    unzip
  ];

  # Update with:
  #   nix build .#yaemoji-idea-plugin.mitmCache.updateScript && ./result
  mitmCache = gradle_9.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  __darwinAllowLocalNetworking = true;

  gradleBuildTask = "buildPlugin";

  gradleFlags = [
    "-Dfile.encoding=utf-8"
    "-DVERSION=${finalAttrs.version}"
  ];

  postPatch = ''
    # buildSearchableOptions runs a headless IDE, which isn't available in the nix sandbox
    echo 'intellijPlatform.buildSearchableOptions = false' >> build.gradle.kts
  '';

  installPhase = ''
    runHook preInstall

    unzip build/distributions/*.zip
    mv yet-another-emoji-support "$out"

    runHook postInstall
  '';

  meta = {
    description = "Yet Another Emoji Support (JetBrains plugin)";
    homepage = "https://github.com/ranma2913/yet-another-emoji-support";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
})
