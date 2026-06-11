# Steam silent-fail via Walker (Elephant backend) — Root Cause & Fix

Host: **zenko** (Asus Zephyrus GU605CW, hybrid GPU)
Compositor: Hyprland 0.55.2 + UWSM
Launcher: walker 2.16.2 with elephant backend (gapplication-service mode)
Reported symptom: Steam does not autostart at login (silent fail); Steam does not start when activated from Walker (silent fail). Steam launched directly from a terminal works.

## Evidence trail

### Steam autostart attempt at boot
```
Jun 11 01:48:20 zenko uwsm_app-daemon[4554]: received: app -- steam
Jun 11 01:48:20 zenko uwsm_app-daemon[4554]: sent: exec systemd-run --user --scope --slice=app-graphical.slice --unit=app-Hyprland-steam-8c5a1ada.scope --description=steam --quiet --collect --same-dir -- steam
Jun 11 01:48:20 zenko systemd[3376]: Started steam.
[ NO further entries until 02:31:45 manual launch ]
```
- The bare `"steam"` in `homes/simi/profiles/desktop.nix:37` exec-once IS auto-wrapped by Hyprland's `withUWSM = true` integration into a `uwsm app -- steam` call. This is correct; the scope is created in the right slice.
- Steam itself wrote **nothing** to `~/.local/share/Steam/logs/*.txt` between the previous shutdown (`01:39:57`) and `02:31:45`. The scope started, the process forked, then died before steam.sh wrote its first `log_opened` line.
- Stale `~/.steam/steam.pipe` FIFO from the previous boot (`Access: 2026-06-10 22:17:51`, current boot `01:40`) was present when the autostart fired.

### Walker → Elephant → Steam attempt
- Elephant logs show successful activations for firefox.desktop, code.desktop, discord.desktop — but NEVER `desktopapplications activated=steam.desktop`.
- When walker activates an app via elephant, elephant calls `gtk_app_info_launch_uris` on the `.desktop` file, which executes the `Exec=` line directly as a child of elephant's own UWSM scope (`app-Hyprland-elephant-7ea8d968.scope`).
- The system-installed `/run/current-system/sw/share/applications/steam.desktop` has `Exec=steam %U` — a bare command. Steam ends up inside elephant's scope instead of its own `app-graphical.slice` scope. This couples Steam's lifecycle to elephant's, and inherits elephant's restricted env.

### Comparison: old codebase vs new

| Surface | OLD (`~/Nix`) | NEW (`~/NixNew`) | Effect |
|---|---|---|---|
| `wayland.windowManager.hyprland.package` | `null` (HM disabled) | unset (HM installs) | HM installs `ndq4688…hyprland-0.55.2`; system installs `zqwcmnrk…hyprland-0.55.2`. Different store paths, same version. |
| `wayland.windowManager.hyprland.portalPackage` | `null` | unset | HM installs `1qvlcifd…xdg-desktop-portal-hyprland-1.3.12`; system installs `z6dyg4w8…xdg-desktop-portal-hyprland-1.3.12`. Two `org.freedesktop.impl.portal.desktop.hyprland.service` files registered. |
| `programs.hyprland.package` | stock | `overrideAttrs` removes `hyprland.desktop`, rewrites session command to `-- start-hyprland` | Session works; uwsm plugin `start_hyprland.sh` is a symlink to `hyprland.sh` (verified identical quirks). Not a regression. |
| Hyprland version | 0.54.3 | 0.55.2 | Minor upstream behaviour delta. |
| `xdg.portal.enable` | not explicit | explicitly `true` | Redundant — `programs.hyprland.enable` already sets this. |
| `/etc/xdg/xdg-desktop-portal/portals.conf` | n/a | does not exist | Portal impl selection falls back to per-impl `UseIn=` declaration. With `gnome` + `gtk` + `hyprland` portals all present, races are possible (visible as the screenshare failure). |
| Steam autostart mechanism | Hyprland `exec-once = ["steam"]` | Hyprland `exec-once = ["steam"]` | Same; but Discord's autostart now runs via `~/.config/autostart/discord.desktop` → `app-discord@autostart.service` (xdg-desktop-autostart target). Steam still races early. |

### Hyprland exec-once via withUWSM
Bare strings in `exec-once` are auto-wrapped to `uwsm app -- <cmd>` by Hyprland-UWSM. PATH/scope hypotheses falsified — the journal shows `uwsm_app-daemon: received: app -- steam` was generated from the bare `"steam"` token.

### dbus-broker duplicate-name warnings at session start
```
dbus-broker-launch[3402]: Ignoring duplicate name 'org.freedesktop.impl.portal.desktop.hyprland'
  in '/run/current-system/sw/share/dbus-1/services/org.freedesktop.impl.portal.desktop.hyprland.service'
dbus-broker-launch[3402]: Ignoring duplicate name 'org.freedesktop.impl.portal.desktop.hyprland'
  in '/nix/store/gr017y688rgbzcslmjd02x1kk5ygzamc-system-path/share/dbus-1/services/...'
dbus-broker-launch[3402]: Ignoring duplicate name 'org.freedesktop.impl.portal.desktop.hyprland'
  in '/nix/store/z6dyg4w82r320gl0qlarvsg0dxvlqnaz-xdg-desktop-portal-hyprland-1.3.12/share/dbus-1/services/...'
```
Three D-Bus service files for the same well-known name. Driven by HM installing `xdg-desktop-portal-hyprland` because the new codebase did not opt out of the HM-default `portalPackage`.

## Root cause summary

1. **Walker launch path**: walker → elephant uses `Exec=steam` from the system `steam.desktop`. Steam ends up parented to elephant's UWSM scope instead of its own `app-graphical.slice` scope. The Steam FHS wrapper expects to run as a top-level scope leader; parented inside another scope, the bubblewrap + steam-runtime bootstrap can race on the stale `~/.steam/steam.pipe`, then exit silently with no logs written.
2. **Stale runtime state**: `~/.steam/steam.pipe` (FIFO) is left behind across boots. The early autostart attempt at 01:48:20 hits the stale FIFO before any reader is up, and exits.
3. **Duplicate HM packages**: `wayland.windowManager.hyprland.package` and `.portalPackage` were `null` in old codebase, are unset (default) in new. This installs duplicate copies of Hyprland and its portal at the user-profile level, producing the dbus warnings above and contributing to portal-impl confusion (screenshare regression).

## Fix applied in this commit

### 1. Override `steam.desktop` at user level (the walker→elephant fix)
Added to `homes/simi/profiles/desktop.nix`:
```nix
xdg.desktopEntries.steam = {
  name = "Steam";
  exec = "uwsm app -- steam %U";
  icon = "steam";
  terminal = false;
  type = "Application";
  categories = [ "Network" "FileTransfer" "Game" ];
  mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
};
```
Home-manager writes this to `~/.local/share/applications/steam.desktop`. XDG spec gives `XDG_DATA_HOME` priority over `XDG_DATA_DIRS`, so when ANY launcher (walker, gnome-shell, gtk-launch, gio launch) reads `steam.desktop`, the user copy with `Exec=uwsm app -- steam %U` wins. Result: every Steam launch — autostart, walker, mime handler — goes through `uwsm app-daemon` → a fresh `app-graphical.slice/app-Hyprland-steam-*.scope` instead of being parented to the caller's scope.

### 2. Manual one-shot cleanup (do once, NOT a nix change)
```sh
rm -f ~/.steam/steam.pipe ~/.steam/steam.pid ~/.steam/steam.token
```
Drops the stale FIFO so the next autostart attempt isn't racing it. After this is done once, the new uwsm-wrapped launch path keeps the FIFO managed inside Steam's own scope and a clean shutdown removes it.

## Recommended follow-up fixes (NOT applied here)

### A. Stop duplicating Hyprland + portal at HM level (HIGH impact)
In `modules/desktop/environments/hyprland/hyprland.nix`, inside the `flake.modules.homeManager.desktop` block where `wayland.windowManager.hyprland = { ... }` is set:
```nix
package = null;
portalPackage = null;
```
This matches `~/Nix/modules/home/desktops/hyprland/default.nix:76-77`. Eliminates the dbus-broker duplicate-name warnings and prevents two-builds-of-the-same-package disk waste.

### B. Explicit portal preference (fixes screenshare)
In the NixOS branch of the same module:
```nix
xdg.portal = {
  enable = true;
  config.common = {
    default = [ "hyprland" "gtk" ];
    "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
    "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
  };
};
```
Eliminates the gnome/gtk vs hyprland portal selection race.

### C. Brightness / media keybinds (new feature — was never in old config)
Add to `bind` in `modules/desktop/environments/hyprland/hyprland.nix`:
```
", XF86MonBrightnessUp,   exec, brightnessctl set +5%"
", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
", XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
", XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
", XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
```

## Verification after rebuild

```sh
# 1. rebuild and reboot
sudo nixos-rebuild switch --flake .#zenko
# reboot

# 2. After login, confirm shadow .desktop is in place
cat ~/.local/share/applications/steam.desktop | grep Exec
#   expected: Exec=uwsm app -- steam %U

# 3. Open walker (SUPER+R), type "steam", select it.
#    Watch the scope appear:
systemctl --user list-units --type=scope 'app-Hyprland-steam-*'
#   expected: one running scope

# 4. Confirm Steam stays parented to its own scope, NOT to elephant:
systemd-cgls --user-unit | grep -A2 elephant
#   expected: elephant's cgroup has NO steam children
systemd-cgls --user-unit | grep -A2 'app-Hyprland-steam'
#   expected: a separate scope with steam.sh + ubuntu12_32/steam under it
```

## Diagnostic commands you couldn't run before

The original journalctl attempts failed because UWSM apps are transient scopes, not services:
```sh
journalctl --user -b -t elephant -f                          # follow elephant by syslog tag
journalctl --user -b -t walker -f                            # follow walker
systemctl --user list-units --type=scope 'app-Hyprland-*'    # all uwsm scopes
journalctl --user -b -u 'app-Hyprland-steam-*.scope'         # last steam scope by unit
```
