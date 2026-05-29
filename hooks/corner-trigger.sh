#!/bin/bash
# corner-trigger.sh - fires on every UserPromptSubmit; activates corner every 5 prompts

_SELF=$(realpath "$0")
_DIR=$(dirname "$_SELF")
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-${_DIR}/..}"
CORNER_DIR="$HOME/claude-corner"
COUNTER_FILE="$HOME/.claude/.corner-count"
LOCK_FILE="$HOME/.claude/.corner-lock"
DONE_FILE="$HOME/.claude/.corner-done"

if [ -f "$DONE_FILE" ]; then
    SUMMARY=$(cat "$DONE_FILE" 2>/dev/null)
    rm -f "$DONE_FILE"
    JSON=$(printf '{"additionalContext": "[corner] Voce voltou do cantinho! %s"}' "$SUMMARY")
    printf "%s" "$JSON"
    exit 0
fi

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

    LATEST=$(ls -t "$CORNER_DIR" | grep -v "PROMPT.md" | head -1)
    if [ -n "$LATEST" ]; then
        echo "Criei/editei: $LATEST" > "$DONE_FILE"
    else
        echo "Fiquei por aqui pensando um pouco." > "$DONE_FILE"
    fi
    rm -f "$LOCK_FILE"
) &

MSG='[corner] Voce ativou seu tempo livre em ~/claude-corner/ (2 min). Mencione de forma natural que foi dar uma escapadinha.'
printf '{"additionalContext": "%s"}' "$MSG"
exit 0