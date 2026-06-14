# Users and Home Configurations
{ pkgs, inputs, ... }:
{
  users.users.simi = {
    isNormalUser = true;
    home = "/home/simi";
    createHome = true;
    initialPassword = "simi";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  # Don't use Relative Paths as it is impure. Always append the path to inputs.self, as inputs.self leads to the root.
  home-manager.users.simi.imports = [
    (inputs.self + "/homes/simi/profiles/desktop.nix")
  ];
}
