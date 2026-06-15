# Users and Home Configurations
{ pkgs, inputs, ... }:
{
  users.users.nacho = {
    isNormalUser = true;
    home = "/home/nacho";
    createHome = true;
    initialPassword = "nacho";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  # Don't use Relative Paths as it is impure. Always append the path to inputs.self, as inputs.self leads to the root.
  home-manager.users.simi.imports = [
    (inputs.self + "/homes/nacho/profiles/server.nix")
  ];
}