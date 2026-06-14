# Kernel Module
{
  flake.modules.nixos.core = { lib, pkgs, ... }: {
    boot.kernelPackages = lib.mkOverride 1250 pkgs.linuxPackages_latest;
  };
}
