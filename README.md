# dotfiles

Arch Linux (Hyprland / i3), managed by mise.

## New machine

```bash
sudo pacman -S --needed git mise
mise bootstrap --adopt https://github.com/<you>/dotfiles
```

Log out, log back in. That's the install.

**If adoption stops and says files conflict** (the machine already has a
`~/.zshrc` or similar that differs from the repo):

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

Edit `~/.config/mise/config.toml`, then:

```bash
mise bootstrap
```

Preview first if unsure: `mise bootstrap --dry-run`

## Undo

```bash
mise dot history --path ~/.zshrc
mise dot rollback ~/.zshrc
mise dot undo
```

## First machine only (nothing published yet)

```bash
sudo pacman -S --needed git mise
install -d ~/.config/mise
cp mise.toml          ~/.config/mise/config.toml
cp mise.omarchy4.toml ~/.config/mise/config.omarchy4.toml
cp -r mise-tasks      ~/.config/mise/tasks
mise dot track ~/.config/mise/config.toml ~/.config/mise/config.omarchy4.toml ~/.config/mise/tasks
mise bootstrap
mise dot origin set https://github.com/<you>/dotfiles --sync sync
```
