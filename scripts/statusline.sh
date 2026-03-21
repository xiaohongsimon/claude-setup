#!/bin/bash
# Claude Code status line: shows model name + context window usage with color-coded progress bar
# Install: cp statusline.sh ~/.claude/ && chmod +x ~/.claude/statusline.sh
# Config:  "statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }

input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Build a 20-character progress bar
FILLED=$((PCT * 20 / 100))
EMPTY=$((20 - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /▓}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

# Color based on usage level
if [ "$PCT" -ge 80 ]; then
  COLOR="🔴"
elif [ "$PCT" -ge 50 ]; then
  COLOR="🟡"
else
  COLOR="🟢"
fi

echo "$COLOR [$MODEL] $BAR $PCT%"
