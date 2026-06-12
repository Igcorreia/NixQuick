# X86 NixOS Installer PXE Configuration
{
  namespace,
  inputs,
  modulesPath,
  ...
}:
let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQyfvGLHb+gMY1dzUZp1ckpktrdF204scLSJc/wxVq0 simi@zenko";
in
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

  ${namespace}.boot.secureBoot = false;

  environment.etc."nixos".source = inputs.self;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Key to access the debuggee installer over SSH.
  users.users.root = {
    openssh.authorizedKeys.keys = [
      sshPubKey
    ];
  };
}
