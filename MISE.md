# mise command reference

Day-to-day commands for this configuration. All commands work from any
directory, because the configuration is installed globally at
`~/.config/mise/config.toml`.

---

## Setup

```bash
mise trust ~/.config/mise/config.toml    # after every edit to the config
mise bootstrap                          # apply everything
mise bootstrap --dry-run                # preview everything
mise bootstrap status                   # what differs from the configuration
```

`mise trust` is required whenever the configuration file changes; mise refuses to
run an untrusted configuration.

---

## Dotfiles

### Applying and previewing

```bash
mise dot apply                # apply tracked/managed dotfiles
mise dot diff                 # show pending changes
mise dot status               # state of every entry
```

`mise dot` is shorthand for `mise bootstrap dotfiles`.

### Tracking a file

```bash
mise dot track ~/.config/foo/bar.toml
```

Adds a `[dotfiles]` entry and saves a baseline checkpoint. The file stays where
it is.

| flag | effect |
| --- | --- |
| `--dry-run` | show how many files and bytes a path expands to; write nothing |
| `--no-autosave` | capture only on explicit `mise dot save` |
| `--encrypt` | encrypt before saving to history (requires `[history.encryption]`) |
| `--os <os>` | declare a platform variant |
| `--profile <name>` | declare a mise-environment variant |

Check the size of a directory before enrolling it:

```bash
mise dot track --dry-run ~/.config/somedir
# ~/.config/somedir: 22,972 files, 1.2 GiB
```

### Saving

With the `history-watch` service installed, edits are saved automatically. To
save on demand:

```bash
mise dot save                       # all tracked files
mise dot save ~/.zshrc              # one file
mise dot watch --once               # single watcher pass
```

### History and rollback

```bash
mise dot history                              # all checkpoints
mise dot history --path ~/.zshrc              # one file
mise dot history --label "omarchy update"     # by label
mise dot history diff --operation --patch     # what changed in an operation

mise dot rollback ~/.zshrc --dry-run          # preview
mise dot rollback ~/.zshrc                    # restore latest differing version
mise dot rollback ~/.zshrc --to <ref>         # restore a specific checkpoint
mise dot undo                                 # reverse the last rollback
```

A rollback is itself recorded as a new checkpoint, so a corrected
configuration still propagates.

### Capturing an operation between checkpoints

Wrap a command that may change many files — a distribution upgrade, a config
migration — so both sides are recorded:

```bash
mise dot capture --label "system update" -- sudo pacman -Syu
mise dot history --label "system update"
mise dot history diff --operation --patch
```

Package and operating-system recovery is separate; use the distro's own
snapshots for that.

### Excluding paths

```bash
mise dot exclude '~/.config/foo/cache/**'      # never capture
mise dot include '~/.config/foo/cache/keep'    # capture again
```

Patterns without `/` match any single path component; patterns containing `/`
are anchored to the tracked root.

### Stopping or removing

```bash
mise dot untrack ~/.config/foo/bar.toml    # stop capture; keep the file
mise dot unapply ~/.config/foo/bar.toml    # remove something mise deployed
```

Removing an entry from the configuration does not remove the file.

### Conflicts

```bash
mise dot conflicts                              # list both sides
mise dot pull --take-remote ~/.zshrc            # accept the incoming version
mise dot pull --keep-local ~/.zshrc             # keep this machine's version
mise dot sync                                   # publish the resolution
```

Conflicts pause publication; nothing writes conflict markers into live files.

---

## Tasks

```bash
mise tasks ls                 # list
mise tasks info <task>        # detail: sources, outputs, dependencies
mise run <task>               # run
mise run --force <task>       # ignore freshness
mise run a ::: b ::: c        # schedule several at once
```

| Task | Purpose |
| --- | --- |
| `zsh-setup` | install or update oh-my-zsh |
| `omarchy-session` | run the omarchy-session upstream installer |
| `displaylink` | DisplayLink dock setup; self-skips without hardware |
| `bootstrap` | runs `zsh-setup` + `omarchy-session`; automatic at the end of `mise bootstrap` |

File tasks live in `mise-tasks/` and are discovered by filename. Metadata goes
in `#MISE` comment directives:

```bash
#!/usr/bin/env bash
#MISE description="What this does"
#MISE sources=["input/**"]
#MISE outputs={ auto = true }
```

`outputs = { auto = true }` keys freshness on a hash of the task definition,
so the task is skipped when nothing changed and re-runs when the task is
edited.

---

## Host packages

```bash
mise bootstrap packages status              # declared vs installed
mise bootstrap packages status --missing    # exit 1 on drift (useful in CI)
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
mise ls                # installed and active versions
mise outdated          # what is behind
mise upgrade           # bump everything
mise use -g node@24    # set one tool globally
mise which node        # which binary wins
mise where node        # install path
mise exec -- <cmd>     # run with the configured tools on PATH
```

---

## Git checkouts

```bash
mise bootstrap repos status
mise bootstrap repos apply            # clone missing, update where safe
mise bootstrap repos update           # fast-forward existing checkouts
mise bootstrap repos exec -- git status
```

Updates only happen when the worktree is clean and the origin matches. Dirty
checkouts are reported rather than reset; `--skip-dirty` skips them and updates
the rest.

---

## systemd user units

```bash
mise bootstrap linux systemd-units status
mise bootstrap linux systemd-units apply --dry-run
mise bootstrap linux systemd-units apply
```

`apply` rewrites changed unit files, runs `systemctl --user daemon-reload`,
enables units per `wanted_by`, and restarts them when `start = true`. mise
writes `~/.config/systemd/user/dev.mise.<name>.service` and owns only files
with that prefix.

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

```bash
mise -E omarchy4 bootstrap              # one command
echo 'env = ["omarchy4"]' > ~/.config/mise/miserc.local.toml   # per machine
mise config                             # show which files are loaded
```

Any configuration section can be overridden per profile in
`mise.<env>.toml` / `config.<env>.toml`.

---

## Diagnostics

```bash
mise doctor                             # installation and configuration health
mise config                             # loaded configuration files
mise env                                # the environment mise would export
mise settings ls                        # effective settings
systemctl --user status dev.mise.mise-history.service    # watcher status
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
mise trust ~/.config/mise/config.toml
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
mise dot origin set <private-repo-url>
mise dot sync
mise bootstrap --adopt <private-repo-url>
```
