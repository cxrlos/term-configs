#!/usr/bin/env bash
# Generates status.json for the firefox dashboard.
# Run via cron: */5 * * * * /path/to/firefox-feed/gen-status.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GPU_TEMP=$(rocm-smi --showtemp --json 2>/dev/null \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
k = next(iter(d))
print(d[k].get('Temperature (Sensor junction) (C)', ''))
" 2>/dev/null)

GPU_UTIL=$(rocm-smi --showuse --json 2>/dev/null \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
k = next(iter(d))
print(d[k].get('GPU use (%)', ''))
" 2>/dev/null)

UPDATES=$(checkupdates 2>/dev/null | wc -l)

cat > "${SCRIPT_DIR}/status.json" <<EOF
{"gpu_temp":${GPU_TEMP:-null},"gpu_util":${GPU_UTIL:-null},"updates":${UPDATES:-0},"updated":"$(date +%H:%M)"}
EOF
