{ config, inputs, ... }: {
  imports = [ inputs.nix-topology.flakeModule ];

  flake.modules.nixos.server.imports = [ inputs.nix-topology.nixosModules.default ];

  perSystem = { system, ... }: {
    packages = {
      topology = config.flake.topology.${system}.config.output;
    };

    # Configure your own topology modules.
    topology.modules = [];
  };
}
