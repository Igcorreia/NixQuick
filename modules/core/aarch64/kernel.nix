# Kernel Module
{
  flake.modules.nixos.aarch64 = { lib, pkgs, ... }: {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  };
}
