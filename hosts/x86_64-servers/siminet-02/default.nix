# Main Host Configuration
# TODO: Configure Server GPU
{ ... }:
{
  imports = [
    ./disko.nix
    ./users.nix
    ./services.nix
    ./programs.nix
  ];

  networking = {
    useDHCP = false;
    interfaces.enp0s20f0u3 = {
      ipv4.addresses = [
        {
          address = "192.168.0.3";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp0s20f0u3";
    };
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  console.keyMap = "pt-latin1";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Lisbon";
  zramSwap.enable = true;

  system.stateVersion = "26.11";
}
