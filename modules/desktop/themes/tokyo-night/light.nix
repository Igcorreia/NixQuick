{ ... }:
import ../_mkTheme.nix {
  themeName = "tokyo-night-light";
  stylixConfig = { pkgs, ... }: {
    stylix = {
      enable = true;
      polarity = "light";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-light.yaml";
      cursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-catppuccin-latte-sky";
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
