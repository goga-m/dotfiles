# mise command reference

Day-to-day commands for this configuration. Everything works from any
directory: the configuration is global at `~/.config/mise/config.toml`, and the
global configuration is trusted by default — there is no `mise trust` step.

---

## Setup

```bash
mise bootstrap                          # apply everything
mise bootstrap --dry-run                # preview everything
mise bootstrap status                   # what differs from the configuration
mise bootstrap plan                     # the declarative resource plan
mise bootstrap --only dotfiles,tools    # a subset
mise bootstrap --skip firewall          # everything except a subset
```

Phase order:

```
accounts → plugins → packages → files → services → firewall → compose
         → repos → dotfiles → shell activation → platform defaults
         → linux user units → user settings → tools → bootstrap task → final hook
```

Each phase is independently inspectable, e.g. `mise bootstrap packages status`.

---

## Dotfiles

`mise dot` is shorthand for `mise bootstrap dotfiles`.

### Applying and previewing

```bash
mise dot status               # state of every entry
mise dot diff                 # pending changes
mise dot apply                # apply
mise dot apply --dry-run
```

### Tracking

```bash
mise dot track ~/.config/foo/bar.toml
mise dot track --dry-run ~/.config/some/dir    # file count + size, writes nothing
```

| flag | effect |
| --- | --- |
| `--dry-run` | show how many files and bytes a path expands to; write nothing |
| `--no-autosave` | capture only on explicit `mise dot save` |
| `--encrypt` | encrypt before saving (requires `[history.encryption]`) |
| `--os <os>` | declare a platform variant |
| `--profile <name>` | declare a mise-environment variant |

Tracking is honored from system and global configuration only. Entries in a
project `mise.toml` are ignored with a warning.

### Saving

```bash
mise dot save                 # all tracked files
mise dot save ~/.zshrc        # one file
mise dot watch --once         # single watcher pass
```

With `[bootstrap.services.mise-history] builtin = "history-watch"` installed,
edits are saved automatically and none of the above is needed.

### History and rollback

```bash
mise dot history
mise dot history --path ~/.zshrc
mise dot history show <id> --patch
mise dot history diff <id1> <id2> --patch

mise dot rollback ~/.zshrc --dry-run
mise dot rollback ~/.zshrc                 # latest version that differs
mise dot rollback --to latest~3 --all
mise dot undo
```

A rollback is itself recorded as a checkpoint, so a corrected configuration
still propagates to other machines.

### Capturing an operation

```bash
mise dot capture --label "system update" -- sudo pacman -Syu
mise dot history --label "system update"
mise dot history diff --operation --patch
```

Package and OS recovery is separate — use the distro's own snapshots.

### Excluding

```bash
mise dot exclude '~/.config/foo/cache/**'
mise dot include '~/.config/foo/cache/keep'
```

Patterns without `/` match any single path component; patterns containing `/`
are anchored to the tracked root. Note `mise dot include` edits the global
`[history] exclude` list — to change one directory's selection, edit its
`include = [...]` field.

### Stopping or removing

```bash
mise dot untrack ~/.config/foo/bar.toml    # stop capture, keep the file
mise dot unapply ~/.config/foo/bar.toml    # remove something mise deployed
```

Removing an entry from the configuration does not remove the file.

### Conflicts

```bash
mise dot conflicts
mise dot conflicts ~/.zshrc
mise dot pull --take-remote ~/.zshrc
mise dot pull --keep-local ~/.zshrc
mise dot pull --take-remote-all
mise dot sync
```

Conflicts pause publication; nothing writes conflict markers into live files.

---

## Tasks

```bash
mise tasks ls
mise tasks info <task>        # sources, outputs, dependencies
mise run <task>
mise run --force <task>
mise run a ::: b ::: c
```

| Task | Purpose |
| --- | --- |
| `zsh-setup` | install or update oh-my-zsh |
| `omarchy-session` | run the omarchy-session upstream installer |
| `displaylink` | DisplayLink dock setup; self-skips without hardware |
| `bootstrap` | runs `zsh-setup` + `omarchy-session`; automatic at the end of `mise bootstrap` |

File tasks live in `~/.config/mise/tasks/`. Metadata goes in `#MISE` directives:

```bash
#!/usr/bin/env bash
#MISE description="What this does"
#MISE sources=["input/**"]
#MISE outputs={ auto = true }
```

---

## Host packages

```bash
mise bootstrap packages status
mise bootstrap packages status --missing    # exit 1 on drift
mise bootstrap packages apply --dry-run
mise bootstrap packages apply
mise bootstrap packages use pacman:htop     # declare and install together
```

Declarative removal:

```toml
[bootstrap.packages]
"pacman:some-package" = { state = "absent" }
```

`"latest"` accepts an already-installed version — `apply` installs what is
missing and does not upgrade on every run.

> On Arch, upgrade with `sudo pacman -Syu`. `mise bootstrap packages upgrade`
> updates only the declared packages, which is a partial upgrade and not
> supported by the distribution.

---

## Development tools

```bash
mise ls
mise outdated
mise upgrade
mise use -g node@24
mise which node
mise where node
mise exec -- <cmd>
```

---

## Git checkouts

```bash
mise bootstrap repos status
mise bootstrap repos apply      # clone missing, update where safe
mise bootstrap repos update     # fast-forward existing checkouts
mise bootstrap repos exec -- git status
```

Updates only happen when the worktree is clean and the origin matches. Dirty
checkouts are reported rather than reset; `--skip-dirty` skips them.

---

## systemd user units

```bash
mise bootstrap linux systemd-units status
mise bootstrap linux systemd-units apply --dry-run
mise bootstrap linux systemd-units apply
```

mise writes `~/.config/systemd/user/dev.mise.<name>.service` and owns only
files with that prefix. `apply` rewrites changed units, runs
`systemctl --user daemon-reload`, enables per `wanted_by`, and restarts when
`start = true`.

---

## Login shell and accounts

```bash
mise bootstrap user status
mise bootstrap user apply --dry-run
mise bootstrap user apply

mise bootstrap accounts status
mise bootstrap accounts apply --dry-run
```

`user apply` appends the configured shell to `/etc/shells` if needed and runs
`chsh -s`. Accounts changes touch the system account database — always read the
dry run first.

---

## Profiles

This setup uses no profiles — both hypr config sets ship everywhere and
Hyprland's version precedence picks per machine. mise profiles still
exist if ever needed:

```bash
mise -E work bootstrap            # loads mise.work.toml / config.work.toml
mise config                       # which files are loaded
```

Any section can be overridden per profile in `config.<env>.toml`.

---

## Diagnostics

```bash
mise doctor
mise config
mise env
mise settings ls
systemctl --user status dev.mise.mise-history.service
```

If the watcher stops:

```bash
systemctl --user reset-failed dev.mise.mise-history.service
mise bootstrap services apply
```

---

## Cheat sheet

```bash
# configuration
mise bootstrap
mise bootstrap --dry-run
mise bootstrap status

# dotfiles
mise dot status
mise dot diff
mise dot track ~/.config/foo/bar.toml
mise dot track --dry-run ~/.config/foo
mise dot save
mise dot history --path ~/.zshrc
mise dot rollback ~/.zshrc
mise dot undo
mise dot untrack ~/.config/foo/bar.toml

# tasks
mise tasks ls
mise run <task>
mise run --force <task>

# packages / tools / repos
mise bootstrap packages status
mise bootstrap packages use pacman:htop
mise outdated
mise use -g node@24
mise bootstrap repos update

# sharing
mise dot sync
mise dot pull
```
