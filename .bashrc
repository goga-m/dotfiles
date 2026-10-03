# Avoid duplicates in bash history
export HISTCONTROL=ignoredups

# Load profile
[ -s "$HOME/.profile" ] && . "$HOME/.profile"

# mise (toolchain, PATH, shims)
eval "$(mise activate bash)"

# Custom aliases
[ -s "$HOME/scripts/aliases.sh" ] && . "$HOME/scripts/aliases.sh" # Load custom aliases if found

# Navigation
if [ -x "/usr/bin/exa" ]; then alias ll="exa -l"; else alias ll="ls -alh"; fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Starship prompt
eval "$(starship init bash)"

# fzf key bindings
[ -s "/usr/share/fzf/key-bindings.bash" ] && source "/usr/share/fzf/key-bindings.bash"
[ -s "/usr/share/fzf/completion.bash" ] && source "/usr/share/fzf/completion.bash"

export PATH="$PATH:$HOME/.config/composer/vendor/bin"

. "$HOME/.atuin/bin/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
export PATH="$PATH:$HOME/go/bin"
