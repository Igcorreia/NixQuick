# Bootloader
{
  flake.modules.nixos.aarch64 =
    {
      lib,
      ...
    }:
    {
      # Boot Options Declarations
      boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;
    };
}
