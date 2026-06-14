# Kernel Module
{
  flake.modules.nixos.x86_64 = { lib, pkgs, ... }: {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
