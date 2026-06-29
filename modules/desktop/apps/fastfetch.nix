# Fastfetch Default Configuration
{ ... }:
{
  flake.modules.homeManager.programs =
    {
      config,
      ...
    }:
    let
      c = base: if config.stylix.enable then config.lib.stylix.colors.withHashtag.${base} else "#c8c8ff";
    in
    {
      programs.fastfetch.settings = {
        display = {
          key.width = 10;
          separator = "";
        };

        logo = {
          source = "nixos_small";
          padding = {
            top = 1;
            left = 1;
          };
        };

        modules = [
          "break"
          {
            type = "command";
            key = " user";
            keyColor = c "base0E";
            text = "echo $USER@$(hostnamectl hostname)";
          }
          {
            type = "os";
            key = " os";
            keyColor = c "base0E";
            format = "{name} {version-id}";
          }
          {
            type = "command";
            key = " kernel";
            keyColor = c "base0D";
            text = "echo $(uname -r | cut -d- -f1) $(uname -m)";
          }
          {
            type = "shell";
            key = "󰞷 shell";
            keyColor = c "base0C";
            format = "{pretty-name}";
          }
          {
            type = "cpu";
            key = " cpu";
            keyColor = c "base0D";
            format = "{name}";
          }
          {
            type = "gpu";
            key = "󰢮 gpu";
            keyColor = c "base0C";
            format = "{vendor} {name}";
          }
          {
            type = "memory";
            key = " ram";
            keyColor = c "base0C";
            format = "{used} / {total} ({percentage})";
          }
          {
            type = "disk";
            folders = "/";
            key = "󰉉 ssd";
            keyColor = c "base0B";
            format = "{size-used} / {size-total} ({size-percentage})";
          }
          {
            type = "colors";
            symbol = "circle";
          }
          "break"
        ];
      };
    };
}
