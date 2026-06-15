# Server Profile
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    gotop
  ];

  programs = {
    fish.enable = true;
    fastfetch.enable = true;

    # Devtools
    vim.enable = true;

    # TODO: Fill These
    git = {
      enable = true;
      settings.user = {
        name = "";
        email = "";
      };
    };
  };
}
