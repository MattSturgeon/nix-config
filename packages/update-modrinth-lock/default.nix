{
  writers,
}:
writers.writePython3Bin "generate-modrinth-lock" {
  flakeIgnore = [
    # Thinks shebang is a block comment
    "E265" # block comment should start with '# '
    "E501" # line too long
  ];
} (builtins.readFile ./generate.py)
