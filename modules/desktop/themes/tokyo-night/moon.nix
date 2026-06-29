{ ... }:
import ../_mkTheme.nix {
  themeName = "tokyo-night-moon";
  stylixConfig = { pkgs, ... }: {
    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-moon.yaml";
      cursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-catppuccin-macchiato-sky";
        size = 24;
      };
      icons = {
        enable = true;
        package = pkgs.nordzy-icon-theme;
        dark = "Nordzy-cyan-dark";
        light = "Nordzy-cyan";
      };
    };
  };
}
