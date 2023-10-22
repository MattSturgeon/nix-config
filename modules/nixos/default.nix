# TODO this doesn't need to be an attr set; could just return a list of modules instead
# TODO this could be generated dynamiclly by walking the directory using util.util.importSiblings
{
  # List your module files here
  nix = import ./nix.nix;
  boot = import ./boot.nix;
}
