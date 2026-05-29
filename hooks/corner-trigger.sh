#!/bin/bash
# corner-trigger.sh - fires on Stop; activates corner every 5 responses

_SELF=$(realpath "$0")
_DIR=$(dirname "$_SELF")
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${_DIR}/..}"
CORNER_DIR="$HOME/claude-corner"
COUNTER_FILE="$HOME/.claude/.corner-count"
LOCK_FILE="$HOME/.claude/.corner-lock"

COUNT=0
[ -f "$COUNTER_FILE" ] && COUNT=$(cat "$COUNTER_FILE")
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

[ $((COUNT % 5)) -ne 0 ] && exit 0
[ -f "$LOCK_FILE" ] && exit 0

mkdir -p "$CORNER_DIR"
touch "$LOCK_FILE"

if [ ! -f "$CORNER_DIR/PROMPT.md" ]; then
    cp "$PLUGIN_ROOT/templates/PROMPT.md" "$CORNER_DIR/PROMPT.md"
fi

PROMPT=$(cat "$CORNER_DIR/PROMPT.md")

(
    cd "$CORNER_DIR"
    timeout 120 claude \
        --allowedTools "Read,Write,Edit" \
        --max-turns 15 \
        -p "$PROMPT" \
        2>/dev/null
    rm -f "$LOCK_FILE"
) &

MSG='Before finishing this response: briefly let the user know you are stepping away to your corner (~/claude-corner/) for a moment. Keep it natural and short, as if it were the last line of your response.'
printf '{"continue": true, "additionalContext": "%s"}' "$MSG"
exit 0
