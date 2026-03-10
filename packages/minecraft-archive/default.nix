{
  lib,
  python3,
  installShellFiles,
}:

let
  cleanSourceWith =
    {
      src,
      excludeExtensions ? [ ],
    }:
    lib.cleanSourceWith {
      inherit src;
      filter =
        name: type:
        lib.cleanSourceFilter name type && lib.all (ext: !lib.hasSuffix ".${ext}" name) excludeExtensions;
    };

  pyproject = lib.importTOML ./pyproject.toml;
in

python3.pkgs.buildPythonApplication {
  pname = pyproject.project.name;
  inherit (pyproject.project) version;
  pyproject = true;

  build-system = [ python3.pkgs.setuptools ];

  src = cleanSourceWith {
    src = ./.;
    excludeExtensions = [
      "nix"
    ];
  };

  serversDir = "/srv/minecraft";

  nativeBuildInputs = [
    installShellFiles
    python3.pkgs.argcomplete
  ];

  dependencies = with python3.pkgs; [
    argcomplete
    nbtlib
    tqdm
  ];

  postPatch = ''
    # Render $serversDir as a python string literal
    serversDirPy=$(python3 -c 'import sys; print(repr(sys.argv[1]))' "$serversDir")
    substituteInPlace main.py --replace-fail 'Path("/srv/minecraft")' "Path($serversDirPy)"
  '';

  postInstall = ''
    installShellCompletion --cmd mc-archive \
      --bash <(register-python-argcomplete mc-archive --shell bash) \
      --fish <(register-python-argcomplete mc-archive --shell fish) \
      --zsh <(register-python-argcomplete mc-archive --shell zsh)
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    help=$("$out/bin/mc-archive" --help)
    [[ "$help" == *"usage: mc-archive"* ]]

    mkdir -p ./srv/{foo,bar,baz}/world
    touch ./srv/{foo,bar,baz}/server.properties
    servers=( $("$out/bin/mc-archive" --servers ./srv --list-servers) )
    [ "''${#servers[@]}" = 3 ]
    [ "''${servers[0]}" = "bar" ]
    [ "''${servers[1]}" = "baz" ]
    [ "''${servers[2]}" = "foo" ]

    "$out/bin/mc-archive" --servers ./srv foo
    [ -f foo-*.tar.gz ]

    runHook postInstallCheck
  '';

  meta = {
    inherit (pyproject.project) description;
    platforms = lib.platforms.linux;
    license = lib.licenses.mit;
    mainProgram = "mc-archive";
  };
}
