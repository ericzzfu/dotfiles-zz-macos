#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
USED=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
CACHE_WRITE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
TOTAL=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

TOTAL_USED=$((USED + CACHE_WRITE + CACHE_READ))
REMAINING=$((TOTAL - TOTAL_USED))

# Format used tokens with decimals for millions
format_used() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        printf "%d.%dm" $((n / 1000000)) $(( (n % 1000000) / 100000 ))
    elif [ "$n" -ge 1000 ]; then
        printf "%dk" $((n / 1000))
    else
        printf "%d" "$n"
    fi
}

# Format total tokens without decimals
format_total() {
    local n=$1
    if [ "$n" -ge 1000000 ]; then
        printf "%dm" $((n / 1000000))
    elif [ "$n" -ge 1000 ]; then
        printf "%dk" $((n / 1000))
    else
        printf "%d" "$n"
    fi
}

PCT=$((TOTAL_USED * 100 / TOTAL))
USED_FMT=$(format_used $TOTAL_USED)
TOTAL_FMT=$(format_total $TOTAL)

# Context color: red <50k left, yellow <75k left, green otherwise
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
CYAN='\033[36m'
MAGENTA='\033[35m'
RESET='\033[0m'

if [ "$REMAINING" -lt 50000 ]; then
    CTX_COLOR=$RED
elif [ "$REMAINING" -lt 75000 ]; then
    CTX_COLOR=$YELLOW
else
    CTX_COLOR=$GREEN
fi

# Git repo and branch
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "")

GIT_INFO=""
if [ -n "$REPO" ]; then
    GIT_INFO=" ${CYAN}${REPO}${RESET}:${MAGENTA}${BRANCH}${RESET}"
fi

echo -e "${MODEL} ${CTX_COLOR}[ctx: ${USED_FMT}/${TOTAL_FMT} (${PCT}%)]${RESET}${GIT_INFO}"
