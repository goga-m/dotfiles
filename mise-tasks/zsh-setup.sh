#!/usr/bin/env bash
#MISE description="Install or update oh-my-zsh itself (plugins come from [bootstrap.repos])"
#
# Port of the first half of run_once_01_setup_zsh.sh.
# The chsh call is now [bootstrap.user].login_shell and the four plugin clones
# are [bootstrap.repos] entries, so all that is left here is OMZ proper.
#
# Safe to re-run: the official installer pulls if OMZ is already installed.

set -uo pipefail

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "== oh-my-zsh already present, updating"
else
    echo "== installing oh-my-zsh"
fi

# RUNZSH=no CHSH=no: don't prompt to launch zsh or change the default shell.
# ZSH= must stay EMPTY: the exported $ZSH from .zshrc otherwise makes the
# installer refuse to update an existing installation.
# --keep-zshrc: ~/.zshrc is dotfile-managed, never let the installer touch it.
ZSH= RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --no-chsh --keep-zshrc \
    || { echo "!! oh-my-zsh installer failed"; exit 1; }

# The four custom plugins are declared in [bootstrap.repos]; verify they landed
# so a failed `bootstrap repos` phase is visible here rather than at shell start.
CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
missing=0
for p in fzf-tab zsh-autosuggestions zsh-syntax-highlighting pnpm; do
    if [ ! -d "$CUSTOM/plugins/$p" ]; then
        echo "!! missing plugin: $p (run: mise bootstrap repos apply)"
        missing=1
    fi
done

[ "$missing" -eq 0 ] && echo "== all zsh plugins present"
exit 0
