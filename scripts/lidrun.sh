#!/usr/bin/env bash
set -uo pipefail

_SCRIPT_SRC="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"
REPO_DIR="$(cd "$(dirname "$_SCRIPT_SRC")/.." && pwd)"
source "$REPO_DIR/zsh/palette.sh"

IDLE_TIMEOUT=15
BATTERY_THRESHOLD=20
WARMUP_SECS=60
DEBUG=0
_BG=0
PID_FILE="/tmp/lidrun.pid"
POLL_INTERVAL=30

_stamp() { printf '%s[%s]%s %s\n' "$_subtle" "$(date '+%H:%M:%S')" "$_nc" "$*"; }

usage() {
    printf '\n'
    printf '  %s%s◆ lidrun%s %s— lid-closed on battery%s\n' "$_bold" "$_foam" "$_nc" "$_subtle" "$_nc"
    printf '\n'
    printf '  Usage: sudo lidrun [OPTIONS]\n'
    printf '\n'
    printf '  %s--t <min>%s      idle timeout in minutes     %s(default: 15)%s\n' "$_iris" "$_nc" "$_subtle" "$_nc"
    printf '  %s--bat <pct>%s    sleep if battery below %%    %s(default: 20)%s\n' "$_iris" "$_nc" "$_subtle" "$_nc"
    printf '  %s--warmup <s>%s   forced-on window at start   %s(default: 60)%s\n' "$_iris" "$_nc" "$_subtle" "$_nc"
    printf '  %s--debug%s        foreground with verbose output\n' "$_iris" "$_nc"
    printf '  %s--stop%s         stop a running background instance\n' "$_iris" "$_nc"
    printf '  %s--status%s       show whether lidrun is active\n' "$_iris" "$_nc"
    printf '  %s--log%s          tail the current log file\n' "$_iris" "$_nc"
    printf '  %s--help%s         show this help\n' "$_iris" "$_nc"
    printf '\n'
}

get_battery_pct() {
    pmset -g batt 2>/dev/null |
        grep -E '[0-9]{1,3}%' |
        awk '{print $3}' |
        sed 's/%.*//' |
        head -1
}

is_ac_connected() {
    pmset -g batt 2>/dev/null | grep -q 'AC Power'
}

is_lid_closed() {
    local state
    state=$(ioreg -r -k AppleClamshellState -d 1 2>/dev/null |
        awk '/AppleClamshellState/ {print $3}' |
        tr '[:upper:]' '[:lower:]')
    case "$state" in
    yes | 1 | true) return 0 ;;
    no | 0 | false) return 1 ;;
    esac
    [[ $(ioreg -n AppleClamshell 2>/dev/null | grep -ic closed) -gt 0 ]]
}

get_idle_secs() {
    ioreg -c IOHIDSystem 2>/dev/null |
        awk '/HIDIdleTime/ {print int($NF/1000000000); exit}'
}

show_status() {
    if [[ -f "$PID_FILE" ]]; then
        local pid
        pid=$(<"$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            _ok "lidrun is running ${_subtle}(PID $pid)${_nc}"
            local latest_log
            latest_log=$(ls -t /tmp/lidrun_*.log 2>/dev/null | head -1)
            [[ -n "$latest_log" ]] && printf '  %sLog  %s%s%s\n' "$_subtle" "$_nc" "$latest_log" "$_nc"
        else
            _warn "stale PID file — process $pid is not running"
            if [[ "$(id -u)" -eq 0 ]]; then
                rm -f "$PID_FILE"
                _info "cleaned up stale PID file"
            else
                _info "run ${_iris}sudo lidrun --status${_nc} to clean it up"
            fi
        fi
    else
        _info "lidrun is not running"
    fi
    exit 0
}

show_log() {
    local latest_log
    latest_log=$(ls -t /tmp/lidrun_*.log 2>/dev/null | head -1)
    if [[ -z "$latest_log" ]]; then
        _err "no log file found"
        exit 1
    fi
    _info "tailing ${_subtle}${latest_log}${_nc}"
    tail -f "$latest_log"
    exit 0
}

stop_instance() {
    [[ -f "$PID_FILE" ]] || {
        _err "no running instance found"
        exit 1
    }
    local pid
    pid=$(<"$PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        _ok "stopped lidrun ${_subtle}(PID $pid)${_nc}"
    else
        _warn "stale PID file — process $pid not running"
        rm -f "$PID_FILE"
    fi
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    --t)
        IDLE_TIMEOUT="$2"
        shift 2
        ;;
    --bat)
        BATTERY_THRESHOLD="$2"
        shift 2
        ;;
    --warmup)
        WARMUP_SECS="$2"
        shift 2
        ;;
    --debug)
        DEBUG=1
        shift
        ;;
    --_bg)
        _BG=1
        shift
        ;;
    --stop) stop_instance ;;
    --status) show_status ;;
    --log) show_log ;;
    --help | -h)
        usage
        exit 0
        ;;
    *)
        _err "unknown option: $1"
        exit 1
        ;;
    esac
done

[[ "$(id -u)" -eq 0 ]] || {
    _err "requires root — run with sudo"
    exit 1
}
[[ "$(uname)" == "Darwin" ]] || {
    _err "macOS only"
    exit 1
}

IDLE_TIMEOUT_SECS=$((IDLE_TIMEOUT * 60))
LOG_FILE="/tmp/lidrun_$(date '+%Y-%m-%d_%H%M%S').log"

if [[ "$_BG" -eq 0 ]]; then
    if [[ -f "$PID_FILE" ]]; then
        existing_pid=$(<"$PID_FILE")
        if kill -0 "$existing_pid" 2>/dev/null; then
            _err "already running (PID $existing_pid) — use --stop first"
            exit 1
        fi
        rm -f "$PID_FILE"
    fi
fi

if [[ "$DEBUG" -eq 0 && "$_BG" -eq 0 ]]; then
    "$0" --_bg --t "$IDLE_TIMEOUT" --bat "$BATTERY_THRESHOLD" --warmup "$WARMUP_SECS" </dev/null >"$LOG_FILE" 2>&1 &
    bg_pid=$!
    printf '%s' "$bg_pid" >"$PID_FILE"
    [[ -n "${SUDO_USER:-}" ]] && chown "$SUDO_USER" "$LOG_FILE" 2>/dev/null || true
    printf '\n'
    _info "lidrun started in background"
    printf '  %sPID      %s%s%s\n' "$_subtle" "$_nc" "$bg_pid" "$_nc"
    printf '  %sTimeout  %s%s min%s\n' "$_subtle" "$_nc" "$IDLE_TIMEOUT" "$_nc"
    printf '  %sBattery  %s≥%s%%%s\n' "$_subtle" "$_nc" "$BATTERY_THRESHOLD" "$_nc"
    printf '  %sWarmup   %s%ss%s\n' "$_subtle" "$_nc" "$WARMUP_SECS" "$_nc"
    printf '  %sLog      %s%s%s\n' "$_subtle" "$_nc" "$LOG_FILE" "$_nc"
    printf '  %sStop     %ssudo lidrun --stop%s\n' "$_subtle" "$_nc" "$_nc"
    printf '  %sStatus   %ssudo lidrun --status%s\n' "$_subtle" "$_nc" "$_nc"
    printf '  %sLog      %ssudo lidrun --log%s\n' "$_subtle" "$_nc" "$_nc"
    printf '\n'
    exit 0
fi

CAFF_PID=""

cleanup() {
    _stamp "${_gold}! restoring sleep settings${_nc}"
    pmset -c disablesleep 0 2>/dev/null || true
    pmset -b disablesleep 0 2>/dev/null || true
    [[ -n "$CAFF_PID" ]] && kill "$CAFF_PID" 2>/dev/null || true
    rm -f "$PID_FILE"
    _stamp "${_pine}✓ cleanup done${_nc}"
}

trap cleanup EXIT INT TERM

printf '\n'
_warn "lid-closed mode active — reduced airflow, monitor temps"
printf '\n'

_stamp "idle timeout: ${_iris}${IDLE_TIMEOUT} min${_nc}  battery floor: ${_iris}${BATTERY_THRESHOLD}%%%${_nc}  warmup: ${_iris}${WARMUP_SECS}s${_nc}"

caffeinate -i &
CAFF_PID=$!
_stamp "${_foam}→ caffeinate started ${_subtle}(PID $CAFF_PID)${_nc}"

pmset -c disablesleep 1 2>/dev/null || true
pmset -b disablesleep 1 2>/dev/null || true
_stamp "${_foam}→ disablesleep ON ${_subtle}(warmup ${WARMUP_SECS}s — lid/battery checks suspended)${_nc}"
sleep "$WARMUP_SECS" &
wait $! || true
_stamp "${_subtle}warmup done — entering normal polling${_nc}"

sleep_prevention_active=0

while true; do
    battery=$(get_battery_pct) || true
    battery=${battery:-100}

    idle_secs=$(get_idle_secs) || true
    idle_secs=${idle_secs:-0}

    ac=$(is_ac_connected && echo 1 || echo 0)
    lid=$(is_lid_closed && echo 1 || echo 0)

    if [[ "$DEBUG" -eq 1 ]]; then
        remaining=$((IDLE_TIMEOUT_SECS - idle_secs)) || true
        [[ "$remaining" -lt 0 ]] && remaining=0
        _stamp "${_subtle}bat:${battery}% ac:${ac} lid:${lid} idle:${idle_secs}s timeout_in:${remaining}s${_nc}"
    fi

    should_prevent=0

    if [[ "$lid" -eq 1 ]]; then
        if [[ "$battery" -lt "$BATTERY_THRESHOLD" ]]; then
            _stamp "${_love}✗ battery ${battery}% < ${BATTERY_THRESHOLD}% — allowing sleep${_nc}"
        elif [[ "$idle_secs" -ge "$IDLE_TIMEOUT_SECS" ]]; then
            _stamp "${_love}✗ idle ${idle_secs}s ≥ ${IDLE_TIMEOUT_SECS}s — allowing sleep${_nc}"
        else
            should_prevent=1
        fi
    fi

    if [[ "$should_prevent" -eq 1 && "$sleep_prevention_active" -eq 0 ]]; then
        pmset -c disablesleep 1 2>/dev/null || true
        _stamp "${_foam}→ disablesleep ON  ${_subtle}(bat:${battery}% idle:${idle_secs}s)${_nc}"
        sleep_prevention_active=1

    elif [[ "$should_prevent" -eq 0 && "$sleep_prevention_active" -eq 1 ]]; then
        pmset -c disablesleep 0 2>/dev/null || true
        _stamp "${_pine}✓ disablesleep OFF${_nc}"
        sleep_prevention_active=0

        if [[ "$lid" -eq 1 ]]; then
            [[ -n "$CAFF_PID" ]] && kill "$CAFF_PID" 2>/dev/null || true
            _stamp "${_pine}✓ triggering sleep${_nc}"
            pmset sleepnow 2>/dev/null || true
            rm -f "$PID_FILE"
            trap - EXIT
            exit 0
        fi
    fi

    sleep "$POLL_INTERVAL" &
    wait $! || true
done
