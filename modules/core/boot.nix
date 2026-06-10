# Boot & Kernel
{
  flake.modules.nixos.core =
    {config,
      namespace,
      lib,
      pkgs,
      ...
    }:
    {
      options.${namespace}.boot.secureBoot = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Secure Boot.";
      };

      config = {
        boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.systemd-boot.editor = false; # Security Measure

        # Lanzaboote overrides Default SystemD-Boot, it must be disabled.
        boot.loader.systemd-boot.enable = lib.mkForce (!config.${namespace}.boot.secureBoot);

        environment.systemPackages = lib.mkIf config.${namespace}.boot.secureBoot [
          pkgs.sbctl
        ];

        boot.lanzaboote = lib.mkIf config.${namespace}.boot.secureBoot {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            enable = true;
            autoReboot = true;
          };
        };
      };
    };
}
