# dotfiles

Personal dotfiles. This branch is a **proof of concept: everything managed with
[mise](https://mise.jdx.dev/) instead of [chezmoi](https://www.chezmoi.io/)**.

Target: **Arch Linux** (Wayland / Hyprland, plus i3). Requires mise **≥ 2026.7.4**
(the release where `mise bootstrap` and `[dotfiles]` went stable). Developed and
validated against **2026.9.9** from Arch `extra`.

> **New here?** Read [MISE.md](./MISE.md) — the daily-use guide mapping
> `chezmoi add` / `chezmoi apply` muscle memory onto mise.

## Install

```bash
# 1. mise (Arch)
sudo pacman -S --needed mise        # needs >= 2026.7.4; extra has 2026.9.9

# 2. clone, point ~/.dotfiles at it, trust, bootstrap
git clone <repo> ~/.local/share/chezmoi
ln -s ~/.local/share/chezmoi ~/.dotfiles     # mise's default dotfiles.root
cd ~/.local/share/chezmoi
mise trust .
mise bootstrap
```

`mise bootstrap` prompts before mutating and uses `sudo` where a package or unit
needs it — keep a terminal handy.

Preview first if you prefer:

```bash
mise bootstrap --dry-run
```

## Day-to-day

```bash
mise dot diff                    # what would change
mise dot apply                   # apply just the files
mise dot add --changed           # capture live edits back (chezmoi re-add)
mise bootstrap                   # apply everything
mise bootstrap status            # whole-machine status
git pull && mise bootstrap       # chezmoi update
```

Full list in [MISE.md](./MISE.md).

## Layout

mise-native: **the repo root is the dotfiles root**, and `~/.dotfiles` is a
symlink to this repo so `dotfiles.root` resolves here.

| Path | What it is |
| --- | --- |
| `mise.toml` | the whole machine: tools, packages, env, dotfiles, systemd units, tasks |
| `mise.omarchy4.toml` | overlay for Omarchy 4 "quattro" (Lua hypr configs) |
| `mise-tasks/` | file-tasks for the parts that stay imperative |
| `.zshrc` `.bashrc` `.profile` `.tigrc` `.wezterm.lua` | top-level sources, mirroring `$HOME` |
| `.config/` | everything under `~/.config`, same tree shape |
| `MISE.md` | daily-use guide |
| `docs/mise-research.md` | the chezmoi→mise capability research this branch came out of |

This replaces chezmoi's `dot_` / `dot_config_` filename encoding — mise mirrors
real `$HOME` paths, and every entry is declared in `[dotfiles]`. That
allow-list is the replacement for `.chezmoiignore`: repo-only files simply never
get an entry.

Because `dotfiles.root` reaches the repo through the `~/.dotfiles` symlink,
`mise dot add` seeds new sources into version control without needing `-s`.

## What replaced what

| was | now |
| --- | --- |
| `run_once_00_install_packages_arch.sh` (~200 lines: 28 pkgs + conflict resolver) | `[bootstrap.packages]` (`pacman:` + `aur:`) |
| `fnm install 22` + `npm i -g pnpm typescript …` | `[tools] node` + `npm:` tools |
| `chsh -s /usr/bin/zsh` | `[bootstrap.user].login_shell` |
| `run_once_01` plugin clones | `[bootstrap.repos]` |
| `run_once_02` rofi theme clone + copy | vendored at `dotfiles/.config/rofi/config.rasi` |
| `run_once_03` pipewire packages | `[bootstrap.packages]` |
| `run_once_03` `usermod -aG audio` | `[bootstrap.users]` (commented out — see below) |
| `run_once_05_displaylink.sh` | `mise run displaylink` |
| `run_once_06_omarchy_session.sh` | `[bootstrap.repos]` + `mise run omarchy-session` |
| `dot_config/systemd/user/*.service` + both `run_onchange_after_apply-systemd-*` | `[bootstrap.linux.systemd.units.*]` |
| `.chezmoiignore` | the `[dotfiles]` allow-list |
| `run_onchange_*` freshness | `outputs = { auto = true }` (keyed on a hash of the task definition) |

## Omarchy 3.x vs Omarchy 4 "quattro"

The desktop host runs Omarchy 3.8 (hyprlang, `~/.local/share/omarchy`), while
the VM runs Omarchy 4.0.4 "quattro" — package-backed (`omarchy-settings` →
`/usr/share/omarchy`) and configured in **Lua**.

Hyprland 0.55+ prefers `hyprland.lua` over `hyprland.conf` whenever both exist,
so only one set may be deployed per machine.

| | Omarchy 3.x (host) | Omarchy 4 quattro (VM) |
| --- | --- | --- |
| entry | `hypr/hyprland.conf` | `hypr/hyprland.lua` |
| overrides | `bindings.conf`, `tiling.conf`, `input.conf`, `autostart.conf`, `workspaces.conf` | `bindings.lua`, `input.lua`, `autostart.lua` |
| defaults | `~/.local/share/omarchy/default/hypr/*.conf` | `/usr/share/omarchy/default/hypr/*.lua` |
| API | `bind = SUPER, J, ...` | `o.bind("SUPER + J", ...)`, `hl.unbind(...)`, `hl.config{}` |
| **selected by** | `mise.toml` (the default) | `mise.omarchy4.toml` via the `omarchy4` profile |

chezmoi picked with `{{ if stat "/usr/share/omarchy/default/hypr/omarchy.lua" }}`.
mise's `[dotfiles]` `source` values are **not templated** and `variants` select
on os/arch/profile only — both machines are `linux-x64`, so it becomes one line
of per-machine setup instead:

```bash
# on a quattro machine, once
echo 'env = ["omarchy4"]' > ~/.config/mise/miserc.local.toml
# or one-off
mise -E omarchy4 bootstrap
```

The `.conf` files stay on disk under quattro (mise 2026.9.9 has no
`mode = "absent"`), but Hyprland ignores them when `hyprland.lua` is present —
same practical outcome as chezmoi's ignore.

Edit whichever pair matches the machine you are changing; they are kept
behaviourally in sync, not mechanically generated from each other.

## Notes

- **`~/.dotfiles` must be a symlink to this repo** (see Install). Without it
  `dotfiles.root` points at a directory that doesn't exist and `mise dot add`
  has nowhere to seed new sources.
- **`chezmoi apply` on this branch is a deliberate no-op.** `.chezmoiignore`
  contains `*` so a stray `chezmoi apply` cannot dump the mise source tree into
  `$HOME`. The real chezmoi setup is on `master`.
- **You still have to `cd` into this repo** for mise to see the config — it is
  project-local, not global. Going global needs two more symlinks
  (`~/.config/mise/config.toml` → `mise.toml`, `config.omarchy4.toml` →
  `mise.omarchy4.toml`) plus dropping the explicit `source =` keys so entries
  resolve through `dotfiles.root` instead of the config file's directory.
- **Machine-specific files are intentionally undeclared**: `hypr/monitors.conf`,
  `hypr/monitors.lua`, `vifm/vifminfo.json`, `aichat/config.yaml`,
  `opencode/opencode.json`. Create them by hand per machine — mise never touches
  what has no `[dotfiles]` entry.
- **`audio` group is commented out.** The old script did `usermod -aG audio`.
  mise manages membership from the user side (`[bootstrap.users.pico] groups =
  ["audio"]`), but `pico` is already in `audio` on this host, so enabling it
  would make your login account declaratively managed for no gain. Uncomment only
  after `mise bootstrap accounts apply --dry-run` reads clean. **Never** set
  `exclusive_groups = true` — it strips every membership not listed.
- **`mise bootstrap --yes` skips mise's prompts but does not supply sudo
  credentials.**
- **Arch + version pins don't mix.** Arch ships only the latest of each package,
  so pinned `pacman:`/`aur:` entries are skipped with a warning. Use `"latest"`.
- **Don't rely on `mise bootstrap packages upgrade` on Arch** — it is a partial
  upgrade, which Arch does not support. Run `sudo pacman -Syu`.
- **Directory copies are additive.** Delete a source file and the deployed copy
  stays behind. `mise dot status` won't flag it.

## Validation performed

Against mise 2026.9.9 in an isolated `$HOME`:

- config parses with **0 unknown-field warnings**
- `mise bootstrap plan` resolves all 27 packages
- `mise bootstrap --dry-run` verified **non-mutating** (nothing created, including by the bootstrap task)
- `mise bootstrap --only dotfiles` deployed **92 files**; exec bits preserved; `dot_gitignore` → `.gitignore` correct
- drift detection produces proper unified diffs; `add --changed` capture direction verified
- tools resolve: `node@22.23.3`, `pnpm@12.8.1`, `pandoc@3.12`, LSP packages
- `omarchy4` profile verified to layer the `.lua` set
- systemd units generate the correct `daemon-reload` / `enable` / `restart` sequence

Known gaps found during validation are listed in [MISE.md §11](./MISE.md).

## Rolling back

This is a branch. `master` still has the working chezmoi setup:

```bash
git checkout master
```

chezmoi leaves ordinary files behind, so nothing needs unwinding beyond switching
back and running `chezmoi apply`.
