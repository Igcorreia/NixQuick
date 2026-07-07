# Desktop User Settings
{
  flake.modules.homeManager.desktop =
    {
      lib,
      namespace,
      ...
    }:
    {
      options.${namespace}.desktop.settings.weather.location = lib.mkOption {
        type = lib.types.str;
        default = "New York";
        description = "Location used for weather widgets.";
      };
    };
}
