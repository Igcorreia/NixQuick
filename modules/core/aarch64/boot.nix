# Bootloader
{
  flake.modules.nixos.x86_64 =
    {
      lib,
      ...
    }:
    {
      # Boot Options Declarations
      boot.loader.generic-extlinux-compatible.enable = lib.mkDefault true;
    };
}
