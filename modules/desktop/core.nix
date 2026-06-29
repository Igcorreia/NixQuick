{
  flake.modules.nixos.desktop =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      # Imports
      imports = [ inputs.stylix.nixosModules.stylix ];

      # System Fonts
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];

      # Wayland / Electron environment
      environment.variables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };
    };

  flake.modules.homeManager.desktop =
    {
      config,
      ...
    }:
    {
      xdg = {
        configFile."uwsm/env".source =
          "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
        mime.enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = false;
        };
      };
    };
}
