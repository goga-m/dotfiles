# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). Target: **Arch Linux** (Wayland / Hyprland, plus i3).

## Install

```bash
# 1. install chezmoi
sudo pacman -S --needed chezmoi

# 2. clone + apply in one step
chezmoi init --apply goga-m
```

That's it — `chezmoi init --apply` clones this repo into `~/.local/share/chezmoi` and applies everything.

Some `run_once_*` scripts run during the first apply and use `sudo` (packages, PipeWire, Rofi theme, oh-my-zsh), so keep a terminal handy for the password prompt.

## Day-to-day

```bash
chezmoi update          # git pull + apply
chezmoi diff            # see what would change
chezmoi apply           # apply only
chezmoi add ~/.config/foo/bar.toml   # start tracking a new file
chezmoi edit ~/.zshrc   # edit the source file in $EDITOR
chezmoi forget ~/.bashrc # stop tracking (keeps the file)
```

## What's inside

| Path | What it is |
| --- | --- |
| `dot_zshrc`, `dot_bashrc`, `dot_profile` | shell config |
| `dot_config/{hypr,i3}` | window managers |
| `dot_config/alacritty`, `dot_wezterm.lua` | terminals |
| `dot_config/{nvim,yazi,vifm}`, `dot_tigrc` | editors & file managers |
| `dot_config/{git,starship.toml,zsh}` | git, prompt, zsh bits |
| `dot_config/systemd/` | user services (udiskie, rofi-clipboard) |
| `bin/` | personal scripts |
| `run_once_*.sh` | one-shot setup (packages, zsh plugins, sound, DisplayLink) |
| `run_onchange_after_*.tmpl` | re-runs when its content changes (systemd reload) |

## Notes

- **Machine-specific files are intentionally ignored** (see `.chezmoiignore`): `hypr/monitors.conf`, `vifm/vifminfo.json`, editor `.git` dirs, etc. Create them by hand per machine.
- **DisplayLink** (`run_once_05_displaylink.sh`) self-skips unless a DisplayLink dock is detected on USB.
- **Re-running a `run_once_*` script**: chezmoi records them in its state DB.

  ```bash
  chezmoi state delete-bucket --bucket=scripts   # forget all, then:
  chezmoi apply
  ```
- **Not managed here**: language runtime versions. Install [`mise`](https://mise.jdx.dev/) and keep `~/.config/mise/config.toml` for that.
