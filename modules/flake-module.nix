{ lib, ... }:
let
  /**
    List the children of `dir`.

    # Inputs

    `dir`

    : Directory to read

    # Type

    ```
    children :: path -> [path]
    ```
  */
  children = dir: with builtins; lib.pipe dir [
    readDir
    attrNames
    (map (name: dir + "/${name}"))
  ];

  /**
    Wrap all files in `dir` as submodule imports.

    # Inputs

    `dir`

    : Directory to package as a module

    # Type

    ```
    wrap :: path -> AttrSet
    ```
  */
  wrap = dir: { imports = children dir; };
in
{
  flake = {
    nixosModules = {
      common = wrap ./common;
      nixos = wrap ./nixos;
    };

    homeModules = {
      common = wrap ./common;
      home = wrap ./home-manager;
    };
  };
}
