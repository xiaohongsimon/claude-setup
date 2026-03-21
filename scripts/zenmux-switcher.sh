#!/bin/bash
# Zenmux multi-account API key switcher for Claude Code
# Supports switching between multiple Zenmux Ultra accounts without restarting
#
# Install:
#   1. cp zenmux-switcher.sh ~/.claude/
#   2. chmod +x ~/.claude/zenmux-switcher.sh
#   3. Add your API keys below
#   4. Set in settings.json: "apiKeyHelper": "bash ~/.claude/zenmux-switcher.sh"
#
# Usage:
#   echo 1 > ~/.claude/zenmux-active   # Switch to account 1
#   echo 2 > ~/.claude/zenmux-active   # Switch to account 2
#
# For Claude Code skills that auto-switch, create skills like:
#   zenmux1: echo 1 > ~/.claude/zenmux-active
#   zenmux2: echo 2 > ~/.claude/zenmux-active

ACTIVE_FILE="$HOME/.claude/zenmux-active"
ACCOUNT=$(cat "$ACTIVE_FILE" 2>/dev/null || echo "1")

case "$ACCOUNT" in
  1) echo "YOUR_ZENMUX_API_KEY_1" ;;
  2) echo "YOUR_ZENMUX_API_KEY_2" ;;
  *) echo "YOUR_ZENMUX_API_KEY_1" ;;  # fallback to account 1
esac
