# Home Manager & Users Design

**Date:** 2026-06-01
**Author:** Zenko

---

## Goal

Define how users are declared, auto-created, and given home-manager configurations in the dendritic NixOS flake. The design must be:

- Ergonomic for forkers: drop a folder in `homes/`, everything works
- Transparent: no magic sidecar files or metadata conventions
- Consistent with the existing dendritic pattern: desktop modules own both their NixOS and HM sides
- Compatible with host-level user attribute overrides (shell, groups, SSH keys)

---

## User Auto-Creation

The presence of `homes/<user>/default.nix` or `homes/<user>@<host>/default.nix` is the trigger for NixOS user creation. An empty folder does not create a user — `default.nix` must exist.

`lib/homes.nix` sets only the bare minimum for each discovered user:

```nix
users.users.<name> = {
  isNormalUser = true;
  home         = "/home/<name>";
};
```

Everything else — shell, extra groups, SSH keys, hashed password — is set in the host config and merges via the NixOS module system normally:

```nix
# hosts/x86_64-nixos/zenko/default.nix
users.users.simi = {
  shell                       = pkgs.fish;
  extraGroups                 = [ "wheel" "video" "input" ];
  openssh.authorizedKeys.keys = [ "ssh-ed25519 ..." ];
};
```

No framework knowledge required. No sidecar file. The module system handles merging.

### Naming Convention

Identical to the existing spec:

- `homes/simi/` — simi exists on every host
- `homes/simi@zenko/` — simi exists only on zenko
- Both present — simi on every host, with zenko-specific HM overrides on zenko

This matches the Snowfall Lib pattern, validated by community usage.

---

## Dual Dendritic Buckets

`lib/flake-parts.nix` defines two flake-parts option types of type `deferredModule`:

| Option | Purpose |
|---|---|
| `flake.modules.nixos.*` | NixOS modules — existing |
| `flake.modules.homeManager.*` | HM modules — new |

Every desktop feature file contributes to either or both buckets. The NixOS and HM sides of a feature live in the same file.

### Example: hyprland.nix

```nix
# modules/desktop/hyprland.nix
{ ... }: {
  # NixOS side
  flake.modules.nixos.desktop = { config, lib, ... }: {
    options.desktops.hyprland = {
      enable   = lib.mkEnableOption "Hyprland";
      settings = lib.mkOption {
        type    = lib.types.attrs;
        default = { };
      };
    };

    config = lib.mkIf config.desktops.hyprland.enable {
      programs.hyprland = { enable = true; withUWSM = true; };
      desktop.enable    = lib.mkDefault true;
    };
  };

  # HM side — injected into all users on hosts where Hyprland is active
  flake.modules.homeManager.desktop = { osConfig, lib, ... }: {
    wayland.windowManager.hyprland.enable =
      lib.mkDefault osConfig.programs.hyprland.enable;
  };
}
```

The `osConfig` argument is provided by HM when running as a NixOS module — it exposes the evaluated NixOS config of the host. No circular dependency: NixOS evaluates first, HM reads the result via `osConfig`.

`lib.mkDefault` ensures every user can override freely in their personal home file. Opt-out is `lib.mkForce false`.

On a server host where `programs.hyprland.enable` is `false`, `osConfig.programs.hyprland.enable` evaluates to `false` and `lib.mkDefault false` is a no-op — the HM desktop bucket is always present in `sharedModules` but activates nothing on non-desktop hosts.

---

## lib/homes.nix Wiring

```nix
home-manager = {
  useGlobalPkgs  = true;
  useUserPackages = true;

  # Shared HM defaults — injected into every user on this host
  sharedModules = [ config.flake.modules.homeManager.desktop ];

  # Per-user personal files
  users = lib.genAttrs users (user: {
    imports = importsForUser hostname user;
    # importsForUser returns: [ homes/simi/default.nix  homes/simi@zenko/default.nix ]
  });
};
```

`sharedModules` is the established HM primitive for this — community-endorsed (NixOS Discourse, HM docs). It applies the desktop HM bucket to all managed users. Personal `homes/` files layer on top and override via `lib.mkForce` or attribute merging.

---

## Directory Structure

```
homes/
  simi/
    default.nix              ← plain HM module, shared across all hosts
  simi@zenko/
    default.nix              ← zenko overrides (touchpad, PT layout)
  simi@tenko/
    default.nix              ← tenko overrides (mice, US-intl layout)

modules/
  desktop/
    hyprland.nix             ← flake.modules.nixos.desktop + flake.modules.homeManager.desktop
    group.nix                ← flake.modules.nixos.desktop
    greeters/
      greetd.nix             ← flake.modules.nixos.desktop
    themes/
      catppuccin-mocha.nix   ← flake.modules.nixos.desktop
  core/
    boot.nix                 ← flake.modules.nixos.common
    nix.nix                  ← flake.modules.nixos.common

lib/
  flake-parts.nix            ← defines flake.modules.nixos and flake.modules.homeManager option types
  homes.nix                  ← scans homes/, wires HM, creates NixOS users
  namespace.nix              ← existing
```

---

## Data Flow

```
import-tree ./modules/
  └─ hyprland.nix contributes to:
       flake.modules.nixos.desktop      ← NixOS: programs.hyprland.enable
       flake.modules.homeManager.desktop ← HM: wayland.windowManager.hyprland.enable (mkDefault)

lib/homes.nix scans homes/
  └─ for host zenko, discovers simi:
       users.users.simi.isNormalUser = true
       home-manager.sharedModules    = [ flake.modules.homeManager.desktop ]
       home-manager.users.simi.imports = [
         homes/simi/default.nix
         homes/simi@zenko/default.nix
       ]

Host zenko/default.nix extends:
  users.users.simi.shell       = pkgs.fish
  users.users.simi.extraGroups = [ "wheel" "video" "input" ]
  desktops.hyprland.enable     = true   ← triggers NixOS cascade
```

---

## Forker Experience

### Add a user to all hosts

```
homes/alice/default.nix
```

```nix
{ pkgs, ... }: {
  home.packages = [ pkgs.neovim ];
  programs.git  = { enable = true; userName = "Alice"; };
}
```

Alice's NixOS account is created. HM activates. Desktop defaults (`wayland.windowManager.hyprland.enable = true`) are injected via `sharedModules`. Zero other files touched.

### Add machine-specific HM overrides

```
homes/alice@mymachine/default.nix
```

```nix
{ ... }: {
  wayland.windowManager.hyprland.settings.input.kb_layout = "us";
}
```

### Add system-level attributes

```nix
# hosts/x86_64-nixos/mymachine/default.nix
users.users.alice = {
  shell       = pkgs.fish;
  extraGroups = [ "wheel" "video" ];
};
```

---

## Key Design Decisions

### Why no sidecar metadata file

Snowfall Lib, the community reference for this pattern, does not auto-set shell or groups from the homes directory either. System-level user attributes belong in host config — they are machine-specific concerns (which wheel user exists, which SSH keys are trusted) and merge cleanly via NixOS without any framework machinery.

### Why dual buckets instead of sidecar HM files

Locality: the NixOS and HM sides of a feature belong together. A developer reading `modules/desktop/hyprland.nix` sees the complete picture. With sidecar files (`hyprland-hm.nix`), the HM side is invisible from the NixOS side and `lib/homes.nix` must manually enumerate injections — breaking auto-discovery.

### Why sharedModules for HM injection

`home-manager.sharedModules` is the established HM primitive for applying modules to all managed users. Using it means no custom injection logic — HM handles merging. Community-endorsed on NixOS Discourse.

### Why osConfig and not specialArgs

`osConfig` is provided by HM automatically when running as a NixOS module. It requires no configuration and avoids specialArgs threading through every module. It is the idiomatic way to read NixOS state from within an HM module.

---

## What is NOT in scope

- Secrets management (passwords, private keys) — handled separately (sops-nix, agenix)
- Multiple HM configurations per user on the same host
- Standalone home-manager outputs
- Darwin support
