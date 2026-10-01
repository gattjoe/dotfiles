#!/usr/bin/env bash
# Chains the ponytail statusline, then appends an OTel reachability indicator.
bash "$(ls -d "$HOME"/.claude/plugins/cache/ponytail/ponytail/*/ | sort -V | tail -1)hooks/ponytail-statusline.sh"

# OTEL_* env vars aren't inherited by child processes, so read config straight from settings.json.
config="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
enabled=$(jq -r '.env.CLAUDE_CODE_ENABLE_TELEMETRY // empty' "$config" 2>/dev/null)
endpoint=$(jq -r '.env.OTEL_EXPORTER_OTLP_ENDPOINT // empty' "$config" 2>/dev/null)

if [ "$enabled" = "1" ] && [ -n "$endpoint" ]; then
    if curl -s -o /dev/null -m 1 "$endpoint"; then
        printf ' \033[38;5;108m[OTEL]\033[0m'
    else
        printf ' \033[38;5;196m[OTEL:UNREACHABLE]\033[0m'
    fi
else
    printf ' \033[38;5;240m[OTEL:OFF]\033[0m'
fi
