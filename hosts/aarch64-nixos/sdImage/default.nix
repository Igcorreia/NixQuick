{
  modulesPath,
  inputs,
  pkgs,
  ...
}:
let
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILQyfvGLHb+gMY1dzUZp1ckpktrdF204scLSJc/wxVq0 simi@zenko";
in
{
  # Use binfmt to build the system instead, so it can pull closure from cache. Uncommenting this will cross-compile the system closure from source! (slow)
  # nixpkgs.buildPlatform.system = "x86_64-linux";
  
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];
  
  environment = {
    etc."nixos".source = inputs.self;
    systemPackages = with pkgs; [
      git
      vim
    ];
  };

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
