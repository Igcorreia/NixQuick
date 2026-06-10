{
  flake.modules.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      # System Dependencies
      networking.networkmanager.enable = true;
      programs = {
        dconf.enable = true;
        uwsm.enable = true;
      };

      environment.systemPackages = with pkgs; [
        brightnessctl
      ];

      # System Fonts
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
    };

  flake.modules.homeManager.desktop =
    { ... }:
    {
      xdg = {
        mime.enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
          setSessionVariables = false;
        };
      };
    };
}
