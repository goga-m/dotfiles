# dotfiles

Arch Linux (Hyprland / i3), managed by mise.

## New machine

```bash
sudo pacman -S --needed git mise
mise bootstrap --adopt https://github.com/goga-m/dotfiles
```

Log out, log back in. That's the install.

**If `~/.config/mise` already exists** (it does as soon as mise has run once)
and isn't a git checkout, adopt refuses. Move it aside and run the same command:

```bash
mv ~/.config/mise ~/.config/mise.bak
mise bootstrap --adopt https://github.com/goga-m/dotfiles
```

**If bootstrap stops on conflicting files** — the machine already has a
`~/.zshrc` that differs from the repo's version:

```bash
mise dot pull --take-remote-all
mise bootstrap
```

**On an Omarchy 4 "quattro" machine**, select the profile before bootstrapping:

```bash
echo 'export MISE_ENV=omarchy4' >> ~/.zshrc
mise bootstrap
```

## Changing anything

Edit `~/.config/mise/mise.toml`, then:

```bash
mise bootstrap
```

Preview first if unsure:

```bash
mise bootstrap --dry-run
```

Push your change back so other machines get it:

```bash
git -C ~/.config/mise commit -am "what changed"
git -C ~/.config/mise push
```

## Undo

```bash
mise dot history --path ~/.zshrc
mise dot rollback ~/.zshrc
mise dot undo
```

## Layout

The repository **is** `~/.config/mise`. Clone it there and everything lines up.

| Path | Role |
| --- | --- |
| `mise.toml` | the machine: tools, packages, dotfiles, services, tasks |
| `mise.omarchy4.toml` | Omarchy 4 "quattro" overlay |
| `tasks/` | file tasks that stay imperative |
| `config.local.toml` | machine-local, mise writes here — do not commit |

Add `config.local.toml` to `.gitignore` so mise's local writes stay off the repo.
