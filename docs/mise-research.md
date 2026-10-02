# Can mise replace chezmoi here? — research notes

Researched against: **mise 2026.3.17** (installed), **2026.9.9-1** (Arch `extra`), **v2026.10.0** (upstream latest),
and this repo at `f2c7b24` (107 tracked files).

---

## TL;DR

**Yes — but not with the mise you currently have installed.**

The thing that made this a "no" until recently is closed. mise grew two features that map almost directly onto
what chezmoi is doing in this repo:

| Feature | Status |
| --- | --- |
| `mise bootstrap` — declarative machine setup (packages, files, services, repos, users, shell) | **stable since v2026.7.4** (July 2026) |
| `[dotfiles]` + `mise bootstrap dotfiles apply/diff/add/status/unapply` | **stable since v2026.7.4** |
| `mise dot track` — bidirectional autosync of files you edit in place | since **v2026.9.2** |
| `mise bootstrap dotfiles diff`, `add --changed`, `manifest = "git"` | since **v2026.8.15** |

Your installed **2026.3.17 has none of it** — `mise dot`, `mise dotfiles`, `mise bootstrap` all error out
(verified locally). `sudo pacman -Sy mise` gets you **2026.9.9**, which has all of the above.

**Recommendation: staged hybrid.** Move packages + dev tools + env + systemd units to mise first (that is where
your repo has the most hand-written shell and the most to gain), keep chezmoi for the ~90 config files until the
mise dotfiles surface has proven itself on this machine for a month. Full migration is viable but is a
rewrite of the repo layout, not a re-pointing.

---

## 1. What this repo actually uses chezmoi for

Inventory of the 107 tracked files, grouped by *capability* rather than path:

| Capability | Where | Volume |
| --- | --- | --- |
| **Plain file deployment** | `dot_zshrc`, `dot_profile`, `dot_tigrc`, `dot_wezterm.lua`, most of `dot_config/*` | ~60 files |
| **Vendored third-party content** | `dot_config/vifm/colors` (29), `dot_config/nvim` (24), `dot_config/yazi/plugins` (12) | ~65 files |
| **Conditional deployment** | `.chezmoiignore`: `stat "/usr/share/omarchy/default/hypr/omarchy.lua"` → hypr `.conf` (Omarchy 3) vs `.lua` (Omarchy 4 quattro) | 10 files |
| **Ignore list** | `.chezmoiignore`: monitors, `vifminfo.json`, `aichat/config.yaml`, `opencode.json`, nested `.git` | 8 entries |
| **System packages** | `run_once_00_install_packages_arch.sh.tmpl` — 28 packages, pacman + yay, with a hand-written conflict resolver | 1 script, ~200 lines |
| **Node runtime + npm globals** | same script: `fnm install 22`, `npm i -g pnpm typescript vscode-langservers-extracted typescript-language-server` | |
| **Shell bootstrap** | `run_once_01_setup_zsh.sh.tmpl` — `chsh` + oh-my-zsh installer + 4 git-cloned plugins | 1 script |
| **Theme install** | `run_once_02_rofi-clipboard-manager.sh.tmpl` — clone dracula/rofi, copy `config1.rasi` | 1 script |
| **Audio setup** | `run_once_03_sound.sh.tmpl` — pipewire packages + `usermod -aG audio` | 1 script |
| **Hardware-conditional** | `run_once_05_displaylink.sh` — self-skips unless a DisplayLink dock is on USB | 1 script |
| **Git checkout + upstream installer** | `run_once_06_omarchy_session.sh.tmpl` | 1 script |
| **systemd user units + reload hook** | `dot_config/systemd/user/{udiskie,omarchy-session-autosave}.service` + `run_onchange_after_apply-systemd-*.sh.tmpl` | 4 files |
| **PATH / env vars** | `dot_zshrc` + `dot_profile` — fnm, PNPM_HOME, go, cargo, hunk, .local/bin | ~15 exports |

Not used: `chezmoi` templates with machine data (`.chezmoidata`), `chezmoi` secrets/age, `bin/` (empty),
`--json`/CI drift checks.

**The honest read:** chezmoi is doing *file deployment* for ~60 files and is otherwise being used as a
**script runner with a state DB**. The `run_once_*`/`run_onchange_after_*` scripts are ~450 lines of
imperative shell that reimplement things mise now has natively.

---

## 2. chezmoi → mise capability map

| chezmoi | mise equivalent | Verdict |
| --- | --- | --- |
| `chezmoi apply` | `mise bootstrap` / `mise bootstrap dotfiles apply` | ✅ |
| `chezmoi diff` | `mise bootstrap dotfiles diff` (unified patches for copy/template, structural summary for symlinks) | ✅ 2026.8.15+ |
| `chezmoi verify` / CI drift | `mise bootstrap status --missing` (exit 1 on drift) | ✅ |
| `chezmoi add ~/x` | `mise bootstrap dotfiles add ~/x` (moves to `dotfiles.root`, links) | ✅ |
| `chezmoi add --changed` | `mise bootstrap dotfiles add --changed` | ✅ 2026.8.15+ |
| `chezmoi edit` | `mise bootstrap dotfiles edit` | ✅ |
| `dot_` / `dot_config_` filename encoding | **not needed** — mise mirrors real `$HOME` paths. Or `dot_prefix = true` for stow-style `dot-foo` → `.foo` | ✅ different, simpler |
| `.chezmoiignore` | inverted model: `[dotfiles]` is an **allow-list**, so repo-only files never need ignoring | ✅ better |
| Go templates | **Tera** templates (`mode = "template"`) — `env`, `vars`, `exec()`, `secret()`, `read_file()` | ⚠️ syntax port |
| `.chezmoidata.toml` | `[vars]` in `mise.toml` | ✅ |
| hostname/username-based machine variance | `MISE_ENV` profiles (`config.work.toml`), `.miserc.toml` / `.miserc.local.toml`, `[dotfiles.X].variants` (`os`, `os/arch`, `profile`, `default`), `auto_env` platform envs (`mise.linux.toml`) | ✅ more explicit |
| `private_` prefix (0600 / 0700) | `permissions = "0600"` per entry | ⚠️ **gap**: parent dirs of tracked files are not chmod'd (see §4.3) |
| `run_onchange_after_*` | `[tasks.X] sources = [...] outputs = { auto = true }` — auto output is keyed on a **hash of the task definition**, which is exactly `run_onchange` semantics | ✅ |
| `run_once_*` | task with an explicit marker in `outputs` (`outputs = ["~/.local/state/mydot/rofi-theme"]`) → skipped once the marker exists | ✅ manual but clean |
| `chezmoi state delete-bucket --bucket=scripts` | `mise run --force <task>` | ✅ |
| `.chezmoiexternal` (pinned externals) | `[bootstrap.repos]` (git, with clean-worktree/ff-only safety) or `http:` backend tools | ✅ |
| age-encrypted secrets | `[history.encryption] recipients = [...]` + `encrypt = true` per file (encrypted *before* entering git; push-time enforcement refuses to publish prior plaintext), or `[bootstrap.secrets]` + [fnox](https://fnox.jdx.dev/) for env-sourced secrets | ✅ different model, arguably stronger |
| `chezmoi archive` / `purge` | `mise bootstrap dotfiles unapply` / `mise implode` | ✅ |
| git source dir | `mise bootstrap --from <url>` / `--adopt <url>` (clone into `$MISE_DATA_DIR/bootstrap-repo`, then bootstrap) | ✅ |

### System packages — the big one

`[bootstrap.packages]` supports **`pacman` and `aur` natively** (also apk/apt/dnf/zypper/brew/brew-cask/flatpak/scoop/winget/mas):

```toml
[bootstrap.packages]
"pacman:zsh"                 = "latest"
"pacman:ttf-jetbrains-mono-nerd" = "latest"
"pacman:starship"             = "latest"
"aur:brave-bin"              = "latest"
"pacman:libreoffice-fresh"   = { state = "absent" }   # declarative removal
```

Verified behaviours relevant to your script:

- `"latest"` **accepts an already-installed version** — apply installs missing, does *not* upgrade every run.
  (This is exactly the bug your `pkg_installed()` rewrite was fixing.)
- Fonts and other non-executable packages work — state comes from the pacman DB, not `command -v`.
- `sudo` is handled: interactive prompt works, non-interactive without passwordless sudo fails and prints the
  command rather than hanging. `system_packages.sudo = false` forbids elevation.
- AUR goes through `yay` (preferred) or `paru`, run as the user, AUR-only mode with `--noconfirm`.
- `mise bootstrap packages status --missing` = a drift check you can put in CI.

**Caveats (Arch-specific, documented):**
- Arch carries only the latest → **version pins are not installable**; pinned `pacman:`/`aur:` entries are
  skipped with a warning. Use `"latest"`.
- `mise bootstrap packages upgrade` = `pacman -Sy` + only the configured packages = a **partial upgrade**,
  which Arch does not support. Keep running `pacman -Syu` yourself.
- mise does **not** replicate your `decide_conflict()` interactive "replace the system package?" prompt.
  Conflicts are delegated to pacman/yay. You lose that nicety; you gain ~120 lines of awk.

### Dev tools — the clearest win

`mise registry` has 976 tools. Every CLI in your install script is available:

```
atuin → aqua:atuinsh/atuin     starship → aqua:starship/starship
zoxide → aqua:ajeetdsouza/zoxide   yazi → aqua:sxyazi/yazi
fzf → aqua:junegunn/fzf        gum → aqua:charmbracelet/gum
pandoc → github:jgm/pandoc     aichat → aqua:sigoden/aichat
neovim → aqua:neovim/neovim   lazydocker → aqua:jesseduffield/lazydocker
delta, fd, ripgrep, bat, ...
```

And **`fnm` disappears entirely**: `[tools] node = "22"` replaces it, and the npm globals become
`[tools] "npm:pnpm" = "latest"` / `"npm:typescript" = ...` via mise's npm backend
(`mise backends` lists `npm`; confirm the shorthand with `mise use -g npm:pnpm` after upgrading —
`mise search npm:typescript` does not resolve backend-prefixed names in 2026.3.17).

That kills: the `fnm env --use-on-cd` eval, the `PNPM_HOME` / `pnpm 12 bin layout` case-statement,
and the `unalias pi` workaround in `.zshrc`.

### systemd user units — kills the `run_onchange` hack

`[bootstrap.linux.systemd.units.<name>]` renders a unit from TOML keys and on `apply` does
`daemon-reload` + `enable`/`disable` + `restart`/`stop` — i.e. it *is* your
`run_onchange_after_apply-systemd-*.sh` scripts, declaratively:

```toml
[bootstrap.linux.systemd.units.udiskie]
description = "udiskie removable media manager"
exec_start  = "/usr/bin/udiskie --tray"
after       = ["graphical-session.target"]
wanted_by   = ["graphical-session.target"]
restart     = "on-failure"
```

Catches: `description`, `after`, `wants`, `requires`, `before`, `binds_to`, `part_of`, `conflicts`,
`exec_start_pre`/`exec_start`/`exec_start_post`, `type`, `restart`, `restart_sec`, `environment`,
`environment_file`, `working_directory`, `standard_output`/`standard_error`, `wanted_by`, `start`.
Timers too (`on_boot_sec`, `on_calendar`, `persistent`, …).

**Catches:** mise writes only `~/.config/systemd/user/dev.mise.<name>.service` — it **generates** units, it
does not adopt your hand-written `udiskie.service`. So those two unit files get rewritten as TOML.
Unit values are Tera-rendered but **`{{ exec() }}` is deliberately unavailable** in them.

---

## 3. What does *not* map cleanly (repo-specific)

| # | Your case | Problem | Workaround |
| --- | --- | --- | --- |
| 1 | **Omarchy 3 vs 4** — `.chezmoiignore` uses `stat("/usr/share/omarchy/default/hypr/omarchy.lua")` to pick `.conf` vs `.lua` | mise `variants` select on `os`/`arch`/`profile` — **no "file exists" selector**. Both machines are `linux-x64`, so `auto_env` doesn't help either. | Per-machine profile: `~/.config/mise/miserc.local.toml` (untracked) with `env = ["omarchy4"]`, and `config.omarchy4.toml` holding the `.lua` entries. One line of per-machine setup replaces the `stat()`. |
| 2 | **oh-my-zsh + 4 git plugins** | No OMZ-aware abstraction. `[bootstrap.repos]` clones them fine, but the OMZ installer itself (`--keep-zshrc`, the `ZSH=` empty-env trick) stays a script. | `[bootstrap.repos]` for the 4 plugins + one `[tasks.omz]` with `sources`/`outputs` for the installer. Or drop OMZ (you're using 5 plugins and starship — a plain zdotdir is a real option). |
| 3 | **DisplayLink USB detection** | No package selector can inspect USB. | Keep it as a guarded task: `[tasks.displaylink] run = "..."` with the detection inside. Unavoidable. |
| 4 | **omarchy-session upstream installer** | Third-party installer script. | `[bootstrap.repos]` for the checkout + `[bootstrap.hooks.post-repos]` (or a task) to run `install-omarchy-session.sh`. |
| 5 | **`usermod -aG audio`** | — | `[bootstrap.users]` / `[bootstrap.groups]` (Linux accounts phase). Check the current-user-group case is supported before relying on it. |
| 6 | **Vendored vifm colors / yazi plugins** | Nothing — but `manifest = "git"` is the right tool: manage only `git ls-files` paths, so ignored junk can never leak. | `[dotfiles."~/.config/vifm"] = { source = "...", mode = "symlink-each", manifest = "git" }` |

---

## 4. Known gaps from real chezmoi→mise migrations

From [jdx/mise discussion #13410](https://github.com/jdx/mise/discussions/13410) — a real 220-entry /
~858-file migration off chezmoi, verified on mise 2026.9.11. Treat this as the honest defect list:

1. **`track <dir>` over-capture.** AI-tool state dirs are huge (`~/.claude` 11k files, `~/.pi` 90k files).
   The reporter's first checkpoint swallowed 33,014 files including agent transcripts.
   *Current docs show `mise dot track --dry-run <dir>` printing file count + bytes, and a warning above
   5,000 files / 256 MiB — appears addressed. Verify on the version you install.*
2. **`exclude` on `track` entries.** Was global-only. *Current docs say a tracked directory accepts
   `exclude` relative to the tracked path — appears addressed.*
3. **Permission capture stops at enrollment — STILL OPEN.** Directories that merely *contain* tracked files
   come back `0755` on a fresh machine, including dirs holding credentials. chezmoi's `private_` covered
   directories. Reporter had to hand-maintain a `fix-perms` task over 11 directories.
   → **For you:** declare `permissions` explicitly on any sensitive directory, or use a
   `[bootstrap.hooks.post-dotfiles]` chmod hook (this is exactly what
   [jonpulsifer/infra ADR-0011](https://github.com/jonpulsifer/infra/blob/main/docs/pages/ADR___0011%20Migrate%20dotfiles%20from%20chezmoi%20to%20mise.md) did).
4. **Nested git repos become gitlinks and silently vanish** (mode `160000`, no `.gitmodules`) — the working
   files are gone on adopt, with no warning.
   → **Low risk for you:** verified — this repo has **zero** nested `.git` dirs today (nvim/yazi/vifm
   vendored as plain files, nested `.git`s are in `.chezmoiignore`). Keep it that way.
5. **Credential-store guard omits files silently at save time.** Files named like `secrets*` are refused; the
   notice shows in `mise dot paths` but **not** in `save`/`status`, which still report `tracked`. One
   reporter lost an age private key they believed was backed up.
   → Run `mise dot paths` after any `track` batch. Don't name files `*secret*` unless you mean it.
6. **No hook after `adopt`/`pull`.** Hooks exist for `pre-/post-dotfiles`, `pre-/post-packages`,
   `pre-/post-repos`, `pre-/post-user`, `final` — and `[history.reload]` fires after rollback/undo — but
   nothing fires on an incoming sync. Where the perms fixup *should* live.

Also from the ADR: *"mise's `[dotfiles]`/`bootstrap` were ~5 weeks old at time of research… some behavior
didn't match documentation and needed empirical verification against a real install rather than trusting the
docs alone."* Two concrete bugs they hit: mise's config auto-discovery collides with a dotfiles-mirrored
`~/.config/mise/config.toml` (they renamed the source to `mise-global-config.toml` with an explicit
`source =`), and Tera string literals don't support `\|` grep BRE escapes.

### Churn risk

This surface is ~3 months old and has already moved twice:

- v2026.7.4 — graduated from experimental
- v2026.7.16 — top-level `mise dotfiles` **hidden and deprecated** in favour of `mise bootstrap dotfiles`
  (warnings in 2027.2.0, removal in 2028.2.0)
- v2026.8.15 — `diff`, `add --changed`, `manifest = "git"`, profile reconciliation
- v2026.9.2 — bidirectional `track` sync
- `auto_env` is **disabled by default**, warns from 2026.12.0, default-on from 2027.6.0

Plan for the CLI to keep shifting for another year.

---

## 5. Options

### A. Staged hybrid — recommended

mise owns: `[tools]` (node, and the ~10 registry-available CLIs), `[bootstrap.packages]` (pacman + aur),
`[env]` (EDITOR, PATH), `[bootstrap.linux.systemd.units]`, `[bootstrap.user].login_shell`,
`[bootstrap.repos]` (omarchy-session, zsh plugins), `[tasks.*]` for the leftovers.
chezmoi owns: the ~90 config files, unchanged.

- **Deletes:** `run_once_00` (~200 lines), `run_once_03`, `run_onchange_after_apply-systemd-*` (both),
  the fnm/PNPM_HOME block in `.zshrc`, the `unalias pi` workaround.
- **Keeps:** everything you already understand about file deployment.
- **Risk:** low. mise and chezmoi don't collide — chezmoi just stops shipping the pieces mise owns.
  `~/.config/mise/config.toml` becomes one more chezmoi-managed file.
- **Effort:** ~an afternoon.

### B. Full migration to mise

Drop chezmoi; `[dotfiles]` + `mise bootstrap` for everything.

- Two sub-flavours: **`mode = "copy"`/`"template"`** (chezmoi-like: source tree → rendered targets), or
  **`mode = "track"`** (jdx's model: no source tree, live files edited in place, watcher autosaves
  checkpoints to a bare git repo at `~/.local/state/mise/history/repo.git`, two-way sync between machines,
  `mise dot rollback`/`undo`).
- `track` is genuinely nicer to *live* with if you have several machines and edit configs from random
  editors/agents — no `chezmoi add` after every change. It is a real mental-model switch: the repo becomes a
  **history store**, not a curated source tree, and there's a daemon involved.
- **Costs you:** the §3 workarounds (Omarchy profile, OMZ task, DisplayLink task), the §4.3 permissions
  hook, a Tera template port, and a repo restructure to flat `$HOME`-mirrored paths.
- **Risk:** medium. Feature is 3 months old; the reporter in #13410 hit 6 real gaps in one week.
- **Effort:** a day-plus, plus the debugging tax of a young feature.

### C. Status quo + mise for tools only

Upgrade mise, put `[tools]` in `~/.config/mise/config.toml`, chezmoi unchanged. Removes fnm and the npm-global
juggling; touches nothing else.

- **Risk:** trivial. **Gain:** smaller than A, but non-zero.

---

## 6. Concrete next steps for option A

```bash
# 1. upgrade mise (Arch extra has everything needed)
sudo pacman -Sy mise            # 2026.3.17 -> 2026.9.9

# 2. sanity-check the new surface
mise bootstrap --help
mise bootstrap packages --help
mise doctor

# 3. prototype in a scratch config before touching the repo
mkdir -p ~/scratch && cd ~/scratch
cat > mise.toml <<'TOML'
[tools]
node = "22"
starship = "latest"
zoxide = "latest"
atuin = "latest"

[bootstrap.packages]
"pacman:ttf-jetbrains-mono-nerd" = "latest"
"aur:brave-bin" = "latest"

[bootstrap.user]
login_shell = "/usr/bin/zsh"
TOML
mise trust mise.toml
mise bootstrap --dry-run
mise bootstrap packages status
```

Then, in repo terms:

| Current file | Becomes |
| --- | --- |
| `run_once_00_install_packages_arch.sh.tmpl` | `[bootstrap.packages]` + `[tools]` in `dot_config/mise/config.toml` |
| `run_once_01_setup_zsh.sh.tmpl` (chsh part) | `[bootstrap.user] login_shell = "/usr/bin/zsh"` |
| `run_once_01_setup_zsh.sh.tmpl` (plugin part) | `[bootstrap.repos]` × 4 + one `[tasks.omz-install]` |
| `run_once_03_sound.sh.tmpl` | `[bootstrap.packages]` (pipewire pkgs) + `[bootstrap.groups]` |
| `run_once_02_rofi-clipboard-manager.sh.tmpl` | `[bootstrap.repos]` (dracula/rofi) + a `[dotfiles]` copy entry |
| `run_once_06_omarchy_session.sh.tmpl` | `[bootstrap.repos]` + `[tasks.omarchy-session-install]` with `outputs = { auto = true }` |
| `run_onchange_after_apply-systemd-*.sh.tmpl` | deleted — `[bootstrap.linux.systemd.units.*]` does the reload/enable/restart |
| `dot_config/systemd/user/*.service` | rewritten as `[bootstrap.linux.systemd.units.*]` TOML |
| `dot_zshrc` fnm/PNPM_HOME/go/cargo/hunk block | `[env]` in `mise.toml` (or delete — mise shims handle PATH) |
| `run_once_05_displaylink.sh` | stays a script, wrapped as `[tasks.displaylink]` |
| everything else | unchanged, still chezmoi |

---

## Sources

- mise dotfiles — https://mise.jdx.dev/dotfiles.html
- mise bootstrap — https://mise.jdx.dev/bootstrap.html
- Bootstrap packages / pacman / AUR — https://mise.jdx.dev/bootstrap/packages/ · `/pacman.html` · `/aur.html`
- systemd user units — https://mise.jdx.dev/bootstrap/systemd.html
- Services — https://mise.jdx.dev/bootstrap/services.html
- Secret inputs — https://mise.jdx.dev/bootstrap/secrets.html
- Repos — https://mise.jdx.dev/bootstrap/repos.html · Login shell — https://mise.jdx.dev/bootstrap/user.html
- Config environments / `auto_env` — https://mise.jdx.dev/configuration/environments.html
- History — https://mise.jdx.dev/history.html
- "Dotfiles That Save Themselves" (@jdx, 2026-09-07) — https://jdx.dev/posts/2026-09-07-dotfiles-that-save-themselves/
- v2026.7.4 "Bootstrap goes stable" — https://github.com/jdx/mise/releases/tag/v2026.7.4
- v2026.7.16 (dotfiles consolidated under `mise bootstrap dotfiles`) — https://github.com/jdx/mise/releases/tag/v2026.7.16
- "Six gaps found migrating a real setup off chezmoi" — https://github.com/jdx/mise/discussions/13410
- ADR-0011: migrate dotfiles from chezmoi to mise — https://github.com/jonpulsifer/infra/blob/main/docs/pages/ADR___0011%20Migrate%20dotfiles%20from%20chezmoi%20to%20mise.md
- chezmoi escape hatches — https://www.chezmoi.io/user-guide/advanced/migrate-away-from-chezmoi/
