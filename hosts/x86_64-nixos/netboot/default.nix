# X86 NixOS Installer PXE Configuration
{
  namespace,
  inputs,
  modulesPath,
  pkgs,
  ...
}:
let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQyfvGLHb+gMY1dzUZp1ckpktrdF204scLSJc/wxVq0 simi@zenko";
in
{
  imports = [ "${modulesPath}/installer/netboot/netboot.nix" ];

  ${namespace}.boot.secureBoot = false;

  boot.blacklistedKernelModules = [ "nouveau" ];

  environment = {
    etc."nixos".source = inputs.self;
    systemPackages = with pkgs; [
      inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.default

      git
      vim
    ];
  };

  services.getty.autologinUser = "root";
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Key to access the debuggee installer over SSH.
  users.users.root = {
    password = "";
    openssh.authorizedKeys.keys = [
      sshPubKey
    ];
  };
}
