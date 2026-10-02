#!/usr/bin/env bash
#MISE description="Install/update omarchy-session via its upstream installer"
#
# Port of run_once_06_omarchy_session.sh.
# The checkout itself is a [bootstrap.repos] entry
# (~/.local/share/omarchy-session/src); this task only runs the installer.
#
# Upstream's installer is deliberately conservative: it only refreshes the
# `ws` / `restore-workspace` shortcuts when they are missing or already managed
# by omarchy-session, so an unrelated `ws` on some other host is left alone
# (no --force).

set -uo pipefail

CHECKOUT="$HOME/.local/share/omarchy-session/src"

# The whole tool drives Hyprland through hyprctl — pointless without it.
if ! command -v hyprctl >/dev/null 2>&1; then
    echo "hyprctl not found (no Hyprland on this machine) - skipping omarchy-session."
    exit 0
fi

if [ ! -d "$CHECKOUT/.git" ]; then
    echo "!! $CHECKOUT not cloned yet - run: mise bootstrap repos apply"
    exit 0
fi

echo "== running upstream installer from $CHECKOUT"
if ! "$CHECKOUT/scripts/install-omarchy-session.sh"; then
    echo "!! omarchy-session installer failed"
    exit 0
fi

# Optional: authoritative live session IDs for Pi / Claude Code / OpenCode.
# This rewrites ~/.claude/settings.json (backed up first) and adds an OpenCode
# plugin, so it is opt-in:
#   "$CHECKOUT/scripts/install-agent-integrations.py" --pi --claude --opencode

echo
echo "Installed. Check it with:  ws st && ws deps"
echo "Autosave unit:  systemctl --user status dev.mise.omarchy-session-autosave.service"
