# Omarchy-style desktop on macOS

Omarchy's feel (keyboard-first tiling, a Super key, a minimal bar, one theme
across tools) on a company-managed Mac, built from Homebrew packages and plain
config files. No SIP changes, no sudo, no LaunchDaemons, no key remapping.

**Super = Option (⌥).** Every Omarchy `SUPER` binding is `alt` in AeroSpace.
Plain ⌘ shortcuts are never touched.

## What's included

| Piece | Tool | Config |
|---|---|---|
| Tiling WM | [AeroSpace](https://github.com/nikitabobko/AeroSpace) | `.config/aerospace/aerospace.toml` |
| Status bar | [SketchyBar](https://github.com/FelixKratz/SketchyBar) | `.config/sketchybar/` (shell plugins) |
| Active-window border | [JankyBorders](https://github.com/FelixKratz/JankyBorders) | `.config/borders/bordersrc` |
| Terminal | Ghostty | `.config/ghostty/config.ghostty` |
| Prompt | starship | `.config/omarchy-macos/starship-base.toml` |
| Shell tools | fzf, fd, eza, bat, ripgrep, zoxide | `.config/zsh/omarchy-macos.zsh` + `ohmyzsh/.zshrc` |
| Themes | `theme-set` | `.config/omarchy-macos/themes/<name>/colors.toml` |
| Launcher | Raycast | bind it to ⌥Space yourself |
| Packages / defaults | `Brewfile`, `defaults.sh` | |

## Install

Homebrew has to exist first (https://brew.sh, or ask IT). Then:

```bash
cd ~/dotfiles && macos/install.sh
```

It is idempotent. It runs `brew bundle`, symlinks the configs (plus
`ohmyzsh/.zshrc` and `shared/.config/nvim`), moves anything in the way to
`~/.local/state/omarchy-macos/backup/<timestamp>/`, sets the `tokyo-night`
theme, applies the macOS defaults (old values saved first), starts the
services and prints what's left to do. `--no-brew` and `--no-defaults` skip
those steps. If you can't write to `/Applications`, run
`export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"` first.

Uninstall (keeps Homebrew packages unless `--remove-packages`):

```bash
~/dotfiles/macos/uninstall.sh
```

### Manual steps

1. **Hide the native menu bar**: System Settings → Control Center →
   "Automatically hide and show the menu bar" → Always.
2. **Free Ctrl+←/→** for word movement in the shell: System Settings →
   Keyboard → Keyboard Shortcuts → Mission Control → untick "Move left/right a
   space".
3. **Raycast hotkey**: Raycast Settings → General → ⌥Space.
4. **Main display**: System Settings → Displays → "Use as: Main display".
   Workspaces 1–5 go there, 6–10 to the other display.
5. **Reduce motion**, if `defaults.sh` says it couldn't set it: System Settings
   → Accessibility → Display → Reduce motion.
6. Log out and back in once.

## Permissions

| App | Permission | Why |
|---|---|---|
| AeroSpace | Accessibility | Move, resize and hide windows. Asked on first launch. |
| JankyBorders | Accessibility, if asked | Track window positions to draw the border. |

Nothing needs Input Monitoring, Screen Recording, Location, Automation or Full
Disk Access. Things left out because they would:
- **Wi-Fi in the bar.** The SSID needs Location; dropped entirely.
- **Scripting "Reduce motion".** Needs Full Disk Access; it's manual step 5.
- **SketchyBar alias items** (mirroring other menu-bar icons) need Screen
  Recording; not used.
- **Launching via AppleScript** needs Automation; `omac-launch` uses `open`.

## Keybindings

⌥ = Super. "Yours" marks your Omarchy overrides from
`omarchy/.config/hypr/bindings.lua`, which win over upstream defaults.

| Action | Omarchy | macOS |
|---|---|---|
| Terminal | Super+Return, Super+Q (yours) | `alt-enter`, `alt-q` |
| Browser | Super+Shift+Return / Super+Shift+B | `alt-shift-enter` / `alt-shift-b` |
| File manager | Super+Shift+F | `alt-shift-f` (Finder) |
| Editor | Super+Shift+N | `alt-shift-n` (nvim in Ghostty) |
| Passwords | Super+Shift+/ | `alt-shift-slash` (1Password) |
| Launcher / menu | Super+Space | ⌥Space → Raycast (not bound in AeroSpace) |
| Close window | Super+C (yours) | `alt-c` |
| Fullscreen | Super+F | `alt-f` |
| Toggle floating | Super+T | `alt-t` |
| Toggle split direction | Super+J | `alt-slash` |
| Cycle layout | Super+L | `alt-comma` (tiles ↔ accordion) |
| Minimize | Super+M | `alt-m` |
| Focus | Super+arrows | `alt-left/down/up/right` (crosses monitors at the edge) |
| Move/swap window | Super+Shift+arrows | `alt-shift-left/down/up/right` |
| Window to monitor | Super+Shift+Ctrl+arrows | `alt-ctrl-shift-left/down/up/right` |
| Workspace to monitor | Super+Shift+Alt+arrows | `alt-ctrl-left/down/up/right` |
| Workspace 1–10 | Super+1…0 | `alt-1` … `alt-0` |
| Window to workspace 1–10 | Super+Shift+1…0 | `alt-shift-1` … `alt-shift-0` |
| Next / previous workspace | Super+Tab / Super+Shift+Tab | `alt-tab` / `alt-shift-tab` |
| Last workspace | Super+Ctrl+Tab | `alt-ctrl-tab` |
| Resize width | Super+− / Super+= | `alt-minus` / `alt-equal` |
| Resize height | Super+Shift+− / Super+Shift+= | `alt-shift-minus` / `alt-shift-equal` |
| Resize mode | none | `alt-r`, then arrows or h/j/k/l, −/= smart resize, `b` balance, Esc/Enter to leave |
| Toggle bar | Super+Shift+Space | `alt-shift-space` |
| Service mode | none | `alt-shift-semicolon`, then Esc reload, `r` reset layout, `f` float, `b` balance, Backspace close others |

### Keys deliberately left alone

- **`alt-h/j/k/l`**: LazyVim's Alt+j/k move-line and zsh Meta. That's why
  windows use arrows.
- **`alt-e/n/u/i/backtick`**: US dead-key accents (á ñ ü î à).
- **`alt-space`**: Raycast.
- **`alt-b`, `alt-d`, `alt-period`, `alt-backspace`**: zsh word editing.

What you lose:
- **Word jumps.** ⌥←/→ (and ⌥⇧ to select) no longer jump by word in text
  fields; use ⌘←/→ for line start/end. In zsh, Ctrl+←/→ (after manual step 2)
  and Alt+b replace them.
- **zsh Meta keys:** Alt+f (forward-word), Alt+c (fzf cd; use `z`/`zi`),
  Alt+t, Alt+q, Alt+m, Alt+r.
- **Characters:** ⌥C ç, ⌥Q œ, ⌥F ƒ, ⌥T †, ⌥M µ, ⌥R ®, ⌥/ ÷, ⌥, ≤, ⌥− –, ⌥= ≠,
  ⌥⇧− — (em dash).

Ghostty sets `macos-option-as-alt = left`. Left ⌥ is Meta for zsh and nvim,
and right ⌥ still types accents. AeroSpace can't tell left ⌥ from right ⌥, so
its bindings fire from either one.

## Themes

```bash
theme-set              # list (* = current)
theme-set catppuccin   # switch bar, borders, Ghostty, starship
```

Ships `tokyo-night` (default), `catppuccin` and `gruvbox`. `theme-set` reads
the theme's `colors.toml` and writes the color includes to
`~/.local/state/omarchy-macos/theme/`. It reloads SketchyBar, updates the
running borders, and sends Ghostty `SIGUSR2` (which reloads its config).
starship picks the new colors up on the next prompt. AeroSpace has no colors.

**Adding a theme** is one directory with one file: create
`macos/.config/omarchy-macos/themes/<name>/colors.toml` in Omarchy's format.
Copy any `themes/<name>/colors.toml` from
[basecamp/omarchy](https://github.com/basecamp/omarchy). Every key the shipped
themes have must be present; `theme-set` stops without changing anything if one
is missing. The shipped palettes and the starship layout come from Omarchy
under the MIT license (`.config/omarchy-macos/LICENSE-omarchy`).

## Machine-specific overrides (gitignored)

- `~/.zshrc.local`: anything work-only (proxies, tokens, aliases).
- `~/.config/omarchy-macos/apps.local.conf`: what the app bindings launch, e.g.

  ```bash
  BROWSER_CMD='open -na "Google Chrome" --args --new-window'
  EDITOR_CMD="open -na Ghostty --args -e /bin/zsh -lc 'exec nvim'"
  ```

  Roles: `TERMINAL_CMD`, `BROWSER_CMD`, `FILES_CMD`, `EDITOR_CMD`,
  `PASSWORDS_CMD`. AeroSpace's TOML can't include files, so you can't add new
  bindings here, only change what the existing ones launch.

## Troubleshooting

**A window vanishes when you switch workspaces and comes back with a
swipe.** It ended up on another macOS Space, which AeroSpace can't manage. It
assumes exactly one Space per display. Open Mission Control (Ctrl+↑):
- Remove every extra Desktop (hover it, click ×).
- Exit any fullscreen app with its green button.
- Log out once after `defaults.sh apply`.

Use ⌥F (AeroSpace fullscreen) rather than macOS fullscreen. Ghostty's ⌘Enter
is set to non-native fullscreen so it stays put.

**Big gap above windows.** `gaps.outer.top` in `aerospace.toml`: 8 on a
notched built-in display (macOS already reserves the bar's strip there), 40
elsewhere.

## Known gaps vs. real Omarchy

- **No dwindle layout.** AeroSpace is i3-style tree tiling. Forks with dwindle
  exist; deliberately not used.
- **No scratchpad, Quake console, window groups/tabs, pseudo-tiling or
  pop-out/pin.** AeroSpace has no equivalent. Accordion layout (`alt-comma`) is
  the closest thing to groups.
- **No workspace overview.** Mission Control still works, but AeroSpace hides
  windows off-screen rather than using Spaces, so it shows them oddly.
- **Focus-follows-mouse** is off. AeroSpace supports it
  (`focus-follows-mouse.enabled`); flip it on if you want it.
- **Per-monitor workspace sets** (each monitor having its own 1–10) don't exist.
  Workspaces are global and pinned to a display.
- **Omarchy menus, notification controls, screenshot/OCR/color-picker
  bindings, web-app bindings** aren't ported. Use Raycast and ⌘⇧5.
- **Super+Return opens a new Ghostty instance** (`open -na`). Opening a window
  in a running instance needs AppleScript, which needs Automation permission.
  `quit-after-last-window-closed` keeps idle instances from piling up.
- **Editor via `open --args -e`.** Not tested on every Ghostty build. If ⌥⇧N
  does nothing, set `EDITOR_CMD` in `apps.local.conf`.
- **Ghostty also reads `~/Library/Application Support/com.mitchellh.ghostty/`.**
  If you have an old config there, it loads too; remove it to avoid surprises.
