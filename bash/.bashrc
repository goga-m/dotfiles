# Avoid duplicates in bash history
export HISTCONTROL=ignoredups

# Load profile
[ -s "$HOME/.profile" ] && . "$HOME/.profile"

# Custom aliases
[ -s "$HOME/scripts/aliases.sh" ] && . "$HOME/scripts/aliases.sh"  # Load custom aliases if found

# Navigation
if [ -x "/usr/bin/exa"  ]; then alias ll="exa -l"; else alias ll="ls -alh"; fi

# Vim
if [ -x "/usr/bin/vim"  ]
then
  alias svim="vim --servername one"
  alias ovim="vim --servername one --remote"
fi

export NVM_DIR="/home/goga/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
