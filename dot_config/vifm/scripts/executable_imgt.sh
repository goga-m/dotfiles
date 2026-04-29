#!/bin/bash
# Image preview for vifm using alacritty terminal graphics

X=$1
Y=$2
COLUMNS=$3
LINES=$4
FILENAME=$5

if [ ! -f "$FILENAME" ]; then
    exit 1
fi

ORIG_WIDTH=$(identify -format "%w" "$FILENAME" 2>/dev/null)
ORIG_HEIGHT=$(identify -format "%h" "$FILENAME" 2>/dev/null)

if [ -z "$ORIG_WIDTH" ] || [ -z "$ORIG_HEIGHT" ]; then
    exit 1
fi

WIDTH=$ORIG_WIDTH
HEIGHT=$ORIG_HEIGHT

TERM_WIDTH=$((COLUMNS * 3))
TERM_HEIGHT=$((LINES * 5))

if [ "$WIDTH" -gt "$TERM_WIDTH" ]; then
    HEIGHT=$((HEIGHT * TERM_WIDTH / WIDTH))
    WIDTH=$TERM_WIDTH
fi

if [ "$HEIGHT" -gt "$TERM_HEIGHT" ]; then
    WIDTH=$((WIDTH * TERM_HEIGHT / HEIGHT))
    HEIGHT=$TERM_HEIGHT
fi

printf '\e]1339;h=%d;w=%d;a=0;x=%d;y=%d;inline=1:%s\e\\\n' "$HEIGHT" "$WIDTH" "$X" "$Y" "$FILENAME"
