{
  # Enable NetworkManager on Desktop Hosts
  flake.modules.nixos.desktop =
    { ... }:
    {
      networking.networkmanager.enable = true;
    };
}
