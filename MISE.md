# mise daily-use guide

You know `chezmoi add` and `chezmoi apply`. Here is the same muscle memory for mise.

Everything is run **from this directory** (`~/.local/share/chezmoi`), because the
config lives here and mise discovers it by walking up from the current directory.

```bash
cd ~/.local/share/chezmoi
```

---

## 0. One-time setup

```bash
# trust this directory's config (mise refuses to run untrusted configs)
mise trust .

# apply everything
mise bootstrap
```

Re-run `mise trust .` any time you edit `mise.toml` — mise re-prompts when the
file changes.

---

## 1. The two commands you already know

| chezmoi | mise |
| --- | --- |
| `chezmoi apply` | `mise bootstrap` |
| `chezmoi diff` | `mise bootstrap dotfiles diff` |

`mise bootstrap` runs **everything**: packages → repos → dotfiles → systemd →
login shell → tools → the `bootstrap` task. If you only touched config files you
want the dotfiles slice instead (much faster):

```bash
mise bootstrap dotfiles apply        # just the files
mise bootstrap dotfiles diff        # what would change
```

Shorthand: `mise dot` is an alias of `mise bootstrap dotfiles`.

```bash
mise dot apply
mise dot diff
mise dot status
```

---

## 2. `chezmoi add` → `mise dot add`

### Adding a file you already have and want tracked

Sources now live at the **repo root**, and `~/.dotfiles` is a symlink to this
repo, so mise's `dotfiles.root` resolves here. That means the source lands in
version control automatically — you only need `-p` so the *entry* goes to this
repo's `mise.toml` rather than the global config:

```bash
# template
mise dot add -p ./mise.toml ~/.config/foo/bar.toml
```

That does three things:
1. copies `~/.config/foo/bar.toml` → `~/.dotfiles/.config/foo/bar.toml` (= this repo)
2. writes `"~/.config/foo/bar.toml" = { mode = "copy" }` into `mise.toml`
3. applies it

⚠️ **The `-p` still matters.** Without it the *entry* is written to
`~/.config/mise/config.toml` instead of this repo — the source is still
version-controlled, but the declaration isn't:

```
$ mise dot add --dry-run ~/.poc-probe2
~/.config/mise/config.toml: "~/.poc-probe2" = { mode = "copy" }   # ← wrong file
cp ~/.poc-probe2 ~/.dotfiles/.poc-probe2                          # ← right place
```

**Habit to build:** `mise dot add -p ./mise.toml <target>`.

### Capturing live edits back to the repo (`chezmoi re-add`)

You edited `~/.zshrc` directly and want that to become the source of truth:

```bash
mise dot add ~/.zshrc              # already-managed file: captures to the repo source
mise dot add --changed             # every drifted copy-mode file at once
```

Preview first — `--dry-run` never writes:

```bash
mise dot add --changed --dry-run
```

Output reads as the copy direction:

```
cp ~/.zshrc /home/pico/.local/share/chezmoi/dotfiles/.zshrc          # capture
cp /home/pico/.local/share/chezmoi/dotfiles/.zshrc ~/.zshrc          # re-apply
```

---

## 3. Seeing what's going on

```bash
mise dot status                    # every dotfile: applied / differs / missing
mise dot diff                      # unified diffs
mise bootstrap status              # everything: packages, repos, units, shell
mise bootstrap plan                # the declarative plan, resource by resource
mise bootstrap plan | tail -1      # "Plan: N create, N update, N unchanged, ..."
```

`mise bootstrap plan` is the nicest overview — one line per resource:

```
unchanged  package:pacman:zsh        installed (5.9-6)   installed (any version)
create     dotfile:~/.zshrc
unknown    service:dev.mise.udiskie
```

---

## 4. Removing things

| you want | do |
| --- | --- |
| stop tracking a file, keep it on disk | delete its line from `[dotfiles]` in `mise.toml` |
| remove a file mise deployed | `mise dot unapply <path>` (needs `--force` if you modified it) |
| remove a package | delete the `[bootstrap.packages]` line, then `sudo pacman -Rns <pkg>` |

Note: deleting an entry from the config does **not** remove the deployed file.
The docs describe `mode = "absent"` for declarative removal, but **mise 2026.9.9
does not implement it** (`unknown mode 'absent', ignoring entry` — verified).
Use `mise dot unapply` instead.

---

## 5. Updating

```bash
# pull the repo and apply — the `chezmoi update` equivalent
git pull && mise bootstrap

# host packages: mise installs missing ones but does NOT upgrade every run
mise bootstrap packages status            # what's missing
mise bootstrap packages upgrade           # upgrade only the declared packages

# ⚠️ on Arch, prefer a real full upgrade instead:
sudo pacman -Syu
# mise's `packages upgrade` is a partial upgrade, which Arch does not support.

# dev tools
mise outdated                            # what's behind
mise upgrade                             # bump everything
mise use -g node@24                      # bump one tool

# git checkouts (zsh plugins, omarchy-session)
mise bootstrap repos status
mise bootstrap repos update              # fast-forward all
```

---

## 6. Tasks (the imperative bits)

```bash
mise tasks ls            # list
mise tasks info <name>   # detail
mise run <name>          # run
mise run --force <name>  # ignore freshness, force re-run
```

| task | what it does |
| --- | --- |
| `mise run zsh-setup` | install/update oh-my-zsh |
| `mise run omarchy-session` | run omarchy-session's upstream installer |
| `mise run displaylink` | DisplayLink dock setup (self-skips with no hardware) |
| `mise run bootstrap` | runs `zsh-setup` + `omarchy-session`; mise runs this automatically at the end of `mise bootstrap` |

### run-once / run-on-change

chezmoi's `run_once_*` had a state DB. mise uses file freshness instead:

```toml
[tasks.something]
run = "./do-it.sh"
sources = ["input/**"]
outputs = { auto = true }   # freshness keyed on a hash of THIS TASK DEFINITION
```

- Skips when nothing changed.
- Re-runs when you edit the task — that is `run_onchange_after_*` semantics.
- `mise run --force something` re-runs regardless (replaces
  `chezmoi state delete-bucket --bucket=scripts`).

---

## 7. Machine profiles (Omarchy 3 vs 4)

`mise.toml` describes the **Omarchy 3.x** host. On an Omarchy 4 "quattro" box,
turn on the overlay once per machine:

```bash
echo 'env = ["omarchy4"]' > ~/.config/mise/miserc.local.toml
```

Or for a single command:

```bash
mise -E omarchy4 bootstrap
```

`mise.omarchy4.toml` layers the Lua hypr configs on top. Verified:

```
$ mise dot status | grep hypr        # base:      .conf only
$ mise -E omarchy4 dot status | grep hypr   # overlay: .conf + .lua
```

Why a profile and not a conditional: chezmoi used
`{{ if stat "/usr/share/omarchy/default/hypr/omarchy.lua" }}`. mise's
`[dotfiles]` `source` values are **not templated** (the `{{ }}` is taken
literally — verified), and `variants` select on os/arch/profile only. Both
machines are `linux-x64`, so platform detection can't separate them.

---

## 8. Handy one-offs

```bash
mise doctor                          # health check
mise config                          # which config files are loaded
mise env                             # the env mise would export
mise exec -- <cmd>                   # run a command with mise's tools on PATH
mise which node                      # which binary wins
mise ls                              # installed tool versions
mise settings ls                     # effective settings
```

---

## 9. Cheat sheet

```bash
cd ~/.local/share/chezmoi

mise trust .                                 # after editing mise.toml
mise bootstrap                               # apply everything
mise bootstrap --dry-run                     # preview everything (verified non-mutating)
mise dot apply                               # apply just the files
mise dot diff                                # diff the files
mise dot status                              # file states
mise dot add -p ./mise.toml ~/X                 # track a new file
mise dot add --changed                       # capture all live edits (chezmoi re-add)
mise dot unapply ~/X                         # remove a deployed file
mise run <task>                              # run a task
mise run --force <task>                      # force it
mise bootstrap status                        # whole-machine status
git pull && mise bootstrap                   # chezmoi update
```

---

## 10. What mise does better here

- **`[dotfiles]` is an allow-list** — no `.chezmoiignore` needed. Repo-only files
  (this guide, `mise.toml`, `mise-tasks/`) simply have no entry.
- **`mise bootstrap plan`** gives a one-line-per-resource view of the whole
  machine, not just files.
- **`--dry-run` is genuinely non-mutating** — verified: nothing is created,
  including by the bootstrap task.
- **Packages know about the package DB.** `"latest"` accepts an already-installed
  version, so fonts and other non-executable packages don't get reinstalled every
  run (the bug the old `command -v` check had).
- **systemd units converge themselves** — `apply` does `daemon-reload` + `enable`
  + `restart`, which is what both `run_onchange_after_apply-systemd-*` scripts
  hand-rolled.
- **fnm is gone.** `[tools] node` + `npm:` tools means no `fnm env`, no
  `PNPM_HOME` case-statement, no `unalias pi`.

## 11. What you lose / watch out for

- **`mise dot add` needs `-p ./mise.toml`** or the entry lands in
  `~/.config/mise/config.toml` instead of this repo. The *source* is fine
  (the `~/.dotfiles` symlink keeps it version-controlled); only the
  declaration escapes.
- **No `mode = "absent"`** in 2026.9.9 — removal is `mise dot unapply`.
- **No `PartOf` / `BindsTo` / `Before` / `Conflicts` / `ExecStartPre` /
  `ExecStartPost` / `ExecStopPost`** in the 2026.9.9 unit schema, despite the
  docs listing them. The omarchy-session unit lost `PartOf=graphical-session.target`
  (it still stops at logout; only "stops when the graphical session ends while
  the user session survives" is missing).
- **No `LogLevelMax`** for units either.
- **Directory `copy` is additive** — delete a source file and the deployed copy
  stays. `mise dot status` won't flag it. (Use `manifest = "git"` with
  `symlink-each` if you want removal tracked.)
- **Copy mode overwrites target edits without warning.** Diff before applying.
- **This surface is ~3 months old** and has already deprecated its own top-level
  command once (`mise dotfiles` → `mise bootstrap dotfiles`, removal 2028.2.0).
  Expect it to keep moving.
