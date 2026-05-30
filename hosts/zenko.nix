{ ... }: {
  # Replace with your actual disk label or UUID (run: lsblk -f)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Use systemd-boot (UEFI) - if you use BIOS/MBR, switch to boot.loader.grub
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "zenko";

  system.stateVersion = "25.11";
}
