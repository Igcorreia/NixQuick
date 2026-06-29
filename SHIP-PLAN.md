# NixQuick — Pre-Ship Checklist

**Goal:** every host (and the `secureBoot` path) evaluates and builds, then ship. Architecture is settled — items below are correctness + polish only.

## Architecture (settled)
- **Themes & shells — one registry pattern.** Each is a single string selector (`desktop.theme`, `compositors.hyprland.shell`; `nullOr str`) validated against a self-registering `_themes`/`_shells` list (internal `listOf str`). 1-line override (no `mkForce`, no `≤1` assertion); a typo trips an assertion that lists the valid names. Consumer flakes add their own by appending to the registry + a `mkIf (== "name")` block — no fork (see README "Extend it"). Theme variants stay base (names registered centrally in `themes/default.nix`); shells self-register per-file in `shells/<name>.nix`. Host turns Hyprland on; each home picks one shell.
- **Components** — internal `enable` bools, additive; a shell flips the ones it wants. `_`-skipped contract in `shells/components/README.md`.
- **Host→home** — defaults flow via `home-manager.sharedModules`; theme/wallpaper keep the `osConfig` default so a home can override per-user.

## Remaining fixes
1. **`modules/core/services.nix:9`** — `dates = "24:00"` is an invalid systemd calendar (breaks `nixos-upgrade.timer` on every host). Set `dates = "04:00";`. Also default `enable = false;` — on a flake system, on-by-default auto-upgrade silently does channel upgrades; let consumers opt in.
2. **`modules/core/boot.nix` (secureBoot)** — confirm the `secureBoot = true` path builds. If lanzaboote's key-enrollment assertion trips, add `includeMicrosoftKeys = true;` to `autoEnrollKeys` (~line 43).
3. **`modules/desktop/compositors/hyprland/shells/waybar.nix:40`** — check `layerrule`; remove if it's an empty/no-op `[ ]`.

## Validation
- [ ] `nix flake check` clean.
- [ ] Installer images evaluate: `nix build .#iso .#sdImage` (+ netboot via devShell).
- [ ] Desktop builds against a consuming flake (`--override-input nixquick path:.`).
- [ ] secureBoot path evaluates with no bricking assertion.
- [ ] Negative checks: enabling two shells trips the `≤1` assertion; a typo'd `theme = "..."` or `shells.<typo>.enable` is a hard eval error, not a silent no-op.

## Docs
- README: lean, themes list correct, consume paths (fork / `flakeModules.default`). ✅
- Full reference → GitHub Wiki (post-ship).
