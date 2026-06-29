# NixQuick
> Why pull your hair wiring everything from scratch when i can do it for you?
---
NixQuick is my personal semi-opinionated Nix Configuration Framework, with ease-of-use in mind. It abstracts away the more annoying parts, for example, manually configuring and ricing every single aspect of Hyprland, and wiring desktop shells, and such.

It also supports servers!

## Modules
NixQuick was designed around easily creating and patching modules for your system.

Home-Manager and NixOS modules are tightly integrated in the same expresssion file, using the Dendritic pattern, provided by flake-parts and import-tree for automatically handling wiring the modules.

You can just fork this project and edit any module you want (or not), then make another flake and import your fork (or base NixQuick), add your own hosts, configure them with programs and users as regular, configure your Home manager setups (Basic Manual Structuring rrquired), use the module options namespace and flip the modules you want applied to the host ON. And if each user has different requirements, you can override these on the Homes side for each user. You can set default behaviors using HomeManager sharedModules.

## Themes

### TokyoNight
- tokyoNight-dark
- tokyoNight-light
- tokyoNight-moon
- tokyoNight-storm
