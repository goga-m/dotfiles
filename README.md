# dotfiles

Arch Linux (Hyprland / i3), managed by mise.

Dotfiles are `copy`-mode entries in `mise.toml`: the repo holds the
sources, `mise bootstrap` copies them onto the live paths. Both Hyprland
config sets (hyprlang `.conf` and Omarchy 4 `.lua`) ship everywhere —
Hyprland's own version precedence picks the right one per machine, so no
profiles or env vars are needed.

## New machine

```bash
sudo pacman -S --needed git mise
git clone https://github.com/goga-m/dotfiles ~/.config/mise
mise bootstrap
```

Log out, log back in. That's the install.

**If `~/.config/mise` already exists** (it does as soon as mise has run
once) and isn't a git checkout, move it aside first:

```bash
mv ~/.config/mise ~/.config/mise.bak
git clone https://github.com/goga-m/dotfiles ~/.config/mise
mise bootstrap
```

Note: `copy` overwrites the live targets (`~/.zshrc` etc.) on every
bootstrap. Machine-local files the repo doesn't declare
(`~/.config/git/config.local`, `~/.config/exa/env`, `monitors.*`, …)
are never touched.

## Changing anything

Edit the source in `~/.config/mise` (e.g. `./.zshrc`), then:

```bash
mise bootstrap
```

Preview first if unsure:

```bash
mise bootstrap --dry-run
```

If you edited a live file directly (e.g. tweaked something in the VM),
capture it back into the repo before applying elsewhere:

```bash
mise dot add --changed
```

Push your change back so other machines get it:

```bash
git -C ~/.config/mise commit -am "what changed"
git -C ~/.config/mise push
```

## Undo

History is plain git:

```bash
git -C ~/.config/mise log --oneline -- .zshrc
git -C ~/.config/mise checkout <commit> -- .zshrc
mise dot apply
```

## Layout

The repository **is** `~/.config/mise`. Clone it there and everything lines up.

| Path | Role |
| --- | --- |
| `mise.toml` | the machine: tools, packages, dotfiles, services, tasks |
| `.zshrc`, `.config/…` | dotfile sources, copied to the matching home paths |
| `tasks/` | file tasks that stay imperative |
| `config.local.toml` | machine-local, mise writes here — do not commit |

Add `config.local.toml` to `.gitignore` so mise's local writes stay off the repo.
