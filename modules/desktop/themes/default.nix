{ ... }:
let
  themes = [
    "catppuccin-mocha"
    "catppuccin-macchiato"
    "catppuccin-latte"
    "catppuccin-frappe"
    "tokyo-night-dark"
    "tokyo-night-storm"
    "tokyo-night-moon"
    "tokyo-night-light"
  ];
in
{
  # System Side Defaults
  flake.modules.nixos.desktop =
    {
      namespace,
      lib,
      config,
      ...
    }:
    {
      options.${namespace}.desktop = {
        theme = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum themes);
          default = null;
          description = "Theme to apply to the desktop environment.";
        };
        wallpaper = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Wallpaper to apply to the desktop environment.";
        };
      };
      config.stylix.image = config.${namespace}.desktop.wallpaper;
    };

  # Home-Manager Overrides
  flake.modules.homeManager.desktop =
    {
      namespace,
      lib,
      osConfig,
      config,
      ...
    }:
    {
      options.${namespace}.desktop = {
        theme = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum themes);
          default = osConfig.${namespace}.desktop.theme;
          description = "Theme to apply to the desktop environment.";
        };
        wallpaper = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = osConfig.${namespace}.desktop.wallpaper;
          description = "Wallpaper to apply to the desktop environment.";
        };
        config.stylix.image = config.${namespace}.desktop.wallpaper;
      };
    };
}
