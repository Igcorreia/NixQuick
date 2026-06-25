# Main Host Configuration
# WARN: Use SOPS only after bootstrapping the system and getting the SSH Host Key inside .sops.yaml
{ config, ... }:
let
  sops = {
    wifiAgd = {
      secret = "wifi-psk";
      template = "wifi-secrets";
    };
  };
in
{
  imports = [
    ./disko.nix
    ./users.nix
    ./services.nix
  ];

  local.boot.secureBoot = true;

  # SOPS Secrets
  sops.secrets.${sops.wifiAgd.secret} = {
    sopsFile = ./secrets/wireless.yaml;
    key = "wifiPsk"; # the key in yaml file that contains the secret
  };

  # Render a wireless secrets file at activation time, not in the Nix store.
  sops.templates.${sops.wifiAgd.template}.content = ''
    WIFI_PSK=${config.sops.placeholder.${sops.wifiAgd.secret}}
  '';

  networking = {
    useDHCP = true;
    wireless = {
      enable = true;
      secretsFile = config.sops.templates.${sops.wifiAgd.template}.path;
      networks."Algardata - wguest" = {
        psk = "@WIFI_PSK@";
      };
    };
    #interfaces.wlan0 = {
    #  ipv4.addresses = [
    #    {
    #      address = "192.168.0.6";
    #      prefixLength = 24;
    #    }
    #  ];
    #};
    #defaultGateway = {
    #  address = "192.168.0.1";
    #  interface = "wlan0";
    #};
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  # Portuguese keyboard is "pt-latin1"
  console.keyMap = "us-intl";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Lisbon";
  zramSwap.enable = true;

  # HW Drivers
  hardware.enableRedistributableFirmware = true;

  # Initrd needs eMMC support
  boot.initrd.availableKernelModules = [
    "mmc_block"
    "sdhci"
    "sdhci_pci"
    "sdhci_acpi"
  ];

  # Space optimization
  documentation = {
    enable = false;
    nixos.enable = false;
    man.enable = false;
  };
  nix.gc = {
    automatic = true;
    dates = "4h";
    options = "--delete-older-than 4h";
  };
  nix.settings.trusted-users = [ "nacho" ]; # User nacho allowed to rebuild system!

  boot.loader.systemd-boot.configurationLimit = 2;
  services.journald.extraConfig = ''
    SystemMaxUse=256M
    SystemKeepFree=1G
    RuntimeMaxUse=16M
  '';

  # DO NOT Alter stateVersion after initial install.
  # This does NOT mean the system is out-of-date or vulnerable.
  system.stateVersion = "26.11";
}
