if zstyle -T ':omz:plugins:pnpm' global-path; then
  # NOTE: `pnpm -g bin` was removed in pnpm 12; calling it returned an error and
  # blanked PNPM_HOME. The global bin dir is simply $PNPM_HOME/bin (pnpm >= 12),
  # or $PNPM_HOME itself on older layouts. Never overwrite an already-set PNPM_HOME.
  : "${PNPM_HOME:=$HOME/.local/share/pnpm}"
  export PNPM_HOME

  # Add pnpm bin directories to $PATH if they exist and are not already present
  for bindir in "$PNPM_HOME/bin" "$PNPM_HOME"; do
    [[ -d "$bindir" ]] && (( ${path[(Ie)$bindir]} == 0 )) && path+=("$bindir")
  done
  unset bindir
fi

# Aliases

alias p='pnpm'

# Dependencies
alias pa='pnpm add'
alias pad='pnpm add --save-dev'
alias pap='pnpm add --save-peer'
alias prm='pnpm remove'
alias pin='pnpm install'
alias pinf='pnpm install --frozen-lockfile'
alias pls='pnpm list'
alias pu='pnpm update'
alias pui='pnpm update --interactive'
alias puil='pnpm update --interactive --latest'

# Global dependencies
alias pga='pnpm add --global'
alias pgls='pnpm list --global'
alias pgrm='pnpm remove --global'
alias pgu='pnpm update --global'

# Run scripts
alias pr='pnpm run'
alias prun='pnpm run'
alias pd='pnpm run dev'
alias pb='pnpm run build'
alias psv='pnpm run serve'
alias pst='pnpm start'
alias pt='pnpm test'
alias ptc='pnpm test --coverage'
alias pln='pnpm run lint'
alias pdocs='pnpm run docs'
alias pfmt='pnpm run format'
alias pex='pnpm exec'
alias pdx='pnpm dlx'

# Misc
alias pi='pnpm init'
alias ppub='pnpm publish'
alias pc='pnpm create'
alias pab='pnpm approve-builds'

# Monorepo
alias pf='pnpm -r --filter'
