{
  flake.modules.homeManager.desktop =
    {
      lib,
      osConfig,
      config,
      namespace,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        # Self-register into the shell selector's allow-list.
        { ${namespace}.desktop.compositors.hyprland._shells = [ "waybar" ]; }

        (lib.mkIf
          (
            osConfig.${namespace}.desktop.compositors.hyprland.enable
            && config.${namespace}.desktop.compositors.hyprland.shell == "waybar"
          )
          {
            # Enable the components this shell uses
            ${namespace}.desktop.compositors.hyprland._components = {
              walker.enable = true;
              mako.enable = true;
              hyprpaper.enable = true;
              hyprpolkit.enable = true;
              hyprlock.enable = true;
              hypridle = {
                enable = true;
                onIdle = lib.getExe pkgs.hyprlock; # Trigger Hyprlock on idle
              };
            };

            programs.waybar = {
              enable = true;
            };
          }
        )
      ];
    };
}
