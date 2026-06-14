{
  flake.modules.nixos.server =
    { ... }:
    {
      networking.useNetworkd = true;
    };
}
