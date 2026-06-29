# NixQuick Module
{ lib, ... }:
{
  # Flake-Level Options
  options.namespace = lib.mkOption {
    type = lib.types.str;
    description = "Namespace that holds NixQuick-related configuration.";
    default = "local";
  };
}
