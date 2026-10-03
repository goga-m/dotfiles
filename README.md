# dotfiles

Development environment and dotfiles managed entirely with
[mise](https://mise.jdx.dev/) — toolchain, host packages, shell configuration,
desktop configuration, systemd user services, and setup tasks in one
declarative configuration.

Target: **Arch Linux** (Wayland / Hyprland, plus i3).

## Requirements

mise **≥ 2026.7.4**, the release in which `mise bootstrap` and `[dotfiles]`
became stable. Verified against **2026.9.9**.

```bash
mise --version
```

## Install

### New machine

The fastest path, if a shared history repository already exists:

```bash
curl https://mise.run | sh
mise bootstrap --adopt <private-repo-url>
```

`--adopt` restores the tracked files and configuration from the repository,
holds anything that conflicts with existing files for a decision, and then runs
the bootstrap. See [Sharing](#sharing).

### From this repository

```bash
# 1. mise
sudo pacman -S --needed mise          # needs >= 2026.7.4

# 2. clone and install the configuration globally
git clone <repo> ~/src/dotfiles
mkdir -p ~/.config/mise
ln -s ~/src/dotfiles/mise.toml           ~/.config/mise/config.toml
ln -s ~/src/dotfiles/mise.omarchy4.toml ~/.config/mise/config.omarchy4.toml

# 3. trust and apply
mise trust ~/.config/mise/config.toml
mise bootstrap --dry-run      # preview
mise bootstrap              # apply
```

`mise bootstrap` prompts before mutating and uses `sudo` where a package or
unit requires it.

The configuration is symlinked into `~/.config/mise/` so that mise reads it
globally — every `mise` command then works from any directory, and editing the
repository edits the live configuration.

## Layout

| Path | Purpose |
| --- | --- |
| `mise.toml` | the machine: tools, packages, environment, dotfiles, systemd units, tasks |
| `mise.omarchy4.toml` | profile overlay for Omarchy 4 "quattro" |
| `mise-tasks/` | file tasks for steps that stay imperative |
| `MISE.md` | command reference for day-to-day use |
| `.zshrc`, `.bashrc`, `.profile`, `.tigrc`, `.wezterm.lua`, `.config/` | a snapshot of the dotfiles, mirroring `$HOME` |

The snapshot mirrors the home directory tree for convenience: it is a browsable
reference and a way to seed a new machine. It is **not** what mise deploys.
Under `mode = "track"` the live files in `$HOME` are the source of truth and
mise history is authoritative — see the next section. If the two drift, the
live files win.

## How configuration is applied

`mise bootstrap` converges the machine in ordered phases:

```
accounts → plugins → packages → files → services → firewall → compose
         → repos → dotfiles → shell activation → platform defaults
         → linux user units → user settings → tools → bootstrap task → final hook
```

Each phase is independently inspectable:

```bash
mise bootstrap status                    # everything
mise bootstrap packages status           # one phase
mise bootstrap plan                      # the full declarative plan
mise bootstrap --only dotfiles,tools     # a subset
mise bootstrap --skip firewall          # everything except a subset
```

## How dotfiles work

Dotfiles use `mode = "track"`. Each file stays exactly where it is — nothing is
symlinked or copied — and mise records checkpoints of it into a local Git
repository. The `history-watch` service saves edits automatically, so a
configuration change made from any editor or agent is captured without a
follow-up command.

```bash
mise dot history --path ~/.zshrc        # checkpoints for a file
mise dot rollback ~/.zshrc --dry-run    # preview restoring the previous version
mise dot rollback ~/.zshrc              # restore it
mise dot undo                           # reverse the rollback
```

Because the live file is the real file, applications can write to it freely and
there is no source tree that silently drifts out of date.

### Tracking a new file

```bash
mise dot track ~/.config/foo/bar.toml
```

This adds the entry to the configuration and saves a baseline checkpoint.

### Tracking a directory

Check the size first. Home directories accumulate caches, session state, and
logs that should not enter history:

```bash
mise dot track --dry-run ~/.config/somedir
# ~/.config/somedir: 22,972 files, 1.2 GiB
```

Prefer tracking individual files, or add `exclude` patterns for the parts that
are state rather than configuration:

```toml
[dotfiles]
"~/.config/vifm" = { mode = "track", exclude = ["vifminfo.json"] }
```

### Stopping tracking

```bash
mise dot untrack ~/.config/foo/bar.toml    # stops capture; the file stays
```

### Seeding a new machine from the snapshot

Without a shared history repository, copy the snapshot into place before
starting to track:

```bash
cd ~/src/dotfiles
cp .zshrc .bashrc .profile .tigrc .wezterm.lua ~/
cp -a .config/. ~/.config/
mise bootstrap
```

Prefer `mise bootstrap --adopt <repo>` when a shared history repository exists
— it restores the tracked versions and handles conflicts properly.

## Sharing

History is local until a remote is connected:

```bash
mise dot origin set <private-repo-url>
```

With `history.sync = "sync"` the watcher publishes saved changes and
periodically fetches and applies changes made on other machines. Use
`--sync manual` when connecting to keep checkpoints local until `mise dot sync`
is run explicitly.

**Use a private repository.** Synchronisation sends earlier checkpoints as
well, so temporary edits can end up in shared history. Configure
[encryption](https://mise.jdx.dev/history.html#encrypted-shared-files) before
the first save of anything sensitive.

Conflicts pause publication rather than inserting conflict markers into live
files:

```bash
mise dot status
mise dot pull --take-remote ~/.zshrc    # or --keep-local
```

Sync resumes once every conflict is resolved.

## Machine profiles

One configuration can describe several machines. This repository targets
Omarchy 3.x by default; `mise.omarchy4.toml` overrides the Hyprland layer for
Omarchy 4 "quattro", which is package-backed and configured in Lua.

| | Omarchy 3.x | Omarchy 4 quattro |
| --- | --- | --- |
| entry | `hypr/hyprland.conf` | `hypr/hyprland.lua` |
| defaults | `~/.local/share/omarchy/default/hypr/*.conf` | `/usr/share/omarchy/default/hypr/*.lua` |
| API | `bind = SUPER, J, ...` | `o.bind("SUPER + J", ...)`, `hl.unbind(...)` |

Select the profile per machine:

```bash
echo 'env = ["omarchy4"]' > ~/.config/mise/miserc.local.toml
# or one-off
mise -E omarchy4 bootstrap
```

Profiles also work for work/personal splits, since any part of the
configuration can be overridden in `mise.<env>.toml`.

## Tasks

```bash
mise tasks ls
mise run <task>
mise run --force <task>
```

| Task | Purpose |
| --- | --- |
| `zsh-setup` | install or update oh-my-zsh |
| `omarchy-session` | run the omarchy-session upstream installer |
| `displaylink` | DisplayLink dock setup; self-skips when no hardware is present |
| `bootstrap` | runs `zsh-setup` and `omarchy-session`; executed automatically at the end of `mise bootstrap` |

Tasks with `sources` and `outputs = { auto = true }` are skipped when nothing
has changed and re-run when the task definition is edited.

## Notes

- **Version pins and rolling releases.** Arch ships only the newest build of
  each package, so pinned `pacman:` / `aur:` entries are skipped with a
  warning. Use `"latest"` and upgrade with `sudo pacman -Syu`;
  `mise bootstrap packages upgrade` performs a partial upgrade, which Arch does
  not support.
- **Machine-specific files are deliberately excluded** from tracking:
  `hypr/monitors.conf`, `git/config.local`, `vifm/vifminfo.json`,
  `yazi/keymap.toml-*`. Create them per machine.
- **Track narrowly.** A tracked directory captures everything under it. Use
  `mise dot track --dry-run <dir>` before enrolling one.
- **`mise bootstrap --yes` skips mise's prompts but does not supply sudo
  credentials.**
- **systemd unit keys.** `part_of`, `binds_to`, `before`, `conflicts`,
  `exec_start_pre`, `exec_start_post`, and `exec_stop_post` are documented but
  not implemented in every release, and `LogLevelMax` is unavailable. Check
  `mise bootstrap linux systemd-units apply --dry-run` before relying on one.
- **This surface moves quickly.** `mise bootstrap` and `[dotfiles]` became
  stable in 2026.7.4 and the CLI has continued to consolidate. Pin a mise
  version if the setup matters to you.

## Further reading

- [MISE.md](./MISE.md) — day-to-day command reference
- [mise dotfiles](https://mise.jdx.dev/dotfiles.html)
- [mise bootstrap](https://mise.jdx.dev/bootstrap.html)
- [Setting up a machine](https://mise.jdx.dev/bootstrap/setup.html)
