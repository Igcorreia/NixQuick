# Base Home-Manager Configuration
{
  flake.modules.nixos.core =
    { inputs, namespace, ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.home-manager
      ];
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs namespace; };

        # Import Core Shared Home-Manager Modules
        # Extend This Per-Module
        # Applies to all hosts
        sharedModules = [
          ( # Set Home-Manager state version to the same as the host state version,
            { osConfig, ... }:
            {
              home.stateVersion = osConfig.system.stateVersion;
            }
          )
        ];
      };
    };
}
