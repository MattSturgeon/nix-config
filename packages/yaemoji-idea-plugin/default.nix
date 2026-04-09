{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gradle_9,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "yet-another-emoji-support";
  version = "1.1.4-beta";

  src = fetchFromGitHub {
    owner = "ranma2913";
    repo = "yet-another-emoji-support";
    # 2026.1 branch
    # https://github.com/ranma2913/yet-another-emoji-support/pull/1
    rev = "0c3d74333586a84408394662898367d8def7f8f6";
    hash = "sha256-6ZlCSc83M6xmBjropkwmmGlKzTPdrba/AMiYTr8tdLA=";
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
