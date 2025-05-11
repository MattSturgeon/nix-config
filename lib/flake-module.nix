{ self, inputs, ... }:
{
  flake = {
    lib = import ./. { inherit inputs self; };
  };
}
