{ ... }:
import ../_mkTheme.nix {
  themeName = "tokyo-night-dark";
  stylixConfig = { pkgs, ... }: {
    stylix = {
      enable = true;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      cursor = {
        package = pkgs.nordzy-cursor-theme;
        name = "Nordzy-catppuccin-mocha-sky";
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
