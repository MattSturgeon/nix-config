# Systems output by this flake.
#
# Can be overridden as a flake input, e.g:
#
#   inputs.systems.url = "path:./systems.nix";
#   inputs.config.inputs.systems.follows = "systems";
#
# See https://github.com/nix-systems/nix-systems
[ "x86_64-linux" ]
