# Main Host Configuration
{ ... }:
{
  imports = [
    ./disko.nix
    ./users.nix
    ./services.nix
  ];

  networking = {
    useDHCP = false;
    interfaces.wlo1 = {
      ipv4.addresses = [
        {
          address = "192.168.0.6";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "wlo1";
    };
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

  # DO NOT Alter stateVersion after initial install.
  # This does NOT mean the system is out-of-date or vulnerable.
  system.stateVersion = "26.11";
}
