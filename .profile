# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

# Exa API keys
# Local secret files (never commit these). Guarded with -f so a missing file
# does not error on shell start.
[[ -f ~/.config/exa/env ]] && source ~/.config/exa/env
