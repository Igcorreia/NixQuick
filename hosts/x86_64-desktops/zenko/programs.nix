# Programs and Services
{ pkgs, ... }:
{
  programs = {
    fish.enable = true;
  
    gamescope.enable = true;
    steam.gamescopeSession.enable = true;
    steam.enable = true;
    };

  services = {
    asusd.enable = true;
    ollama = {
      enable = false;
      package = pkgs.ollama-cuda;
    };
  };
}
