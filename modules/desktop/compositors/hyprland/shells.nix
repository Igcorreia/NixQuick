# Shell Manager — registry, selector, and validation.
# Each shell self-registers into `_shells` (see shells/<name>.nix); `shell` picks one.
# A consumer flake adds its own shell the same way: register a name + a
# `mkIf (shell == "<name>")` block — no fork needed.
{
  flake.modules.homeManager.desktop =
    {
      config,
      lib,
      namespace,
      ...
    }:
    let
      cfg = config.${namespace}.desktop.compositors.hyprland;
    in
    {
      options.${namespace}.desktop.compositors.hyprland = {
        _shells = lib.mkOption {
          internal = true;
          default = [ ];
          type = lib.types.listOf lib.types.str;
          description = "Hyprland Shell Registry.";
        };
        shell = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Which Hyprland Shell To Enable. (Must exist in the shell registry.)";
        };
      };

      # Check if current shell is null or an element of the registry
      config.assertions = [
        {
          assertion = cfg.shell == null || builtins.elem cfg.shell cfg._shells;
          message = "[ ${namespace}.desktop.compositors.hyprland.shell ]: \"${toString cfg.shell}\" is not a registered shell. Available: ${builtins.concatStringsSep ", " cfg._shells}.";
        }
      ];
    };
}
