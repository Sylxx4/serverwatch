#!/bin/bash
LOG_DIR='/var/log/serverwatch'
LOG_FILE="${LOG_DIR}/health.log"
INTERVAL=60
MAX_LOG_LINES=1000

set -euo pipefail

if [[ ! -d "$LOG_DIR" ]]; then
    echo "ERROR: Log directory $LOG_DIR does not exist." >&2
    exit 1
fi

log_entry() {
    local level="$1" message="$2" timestamp
    timestamp=$(date '+%Y-%m-%dT%H:%M:%S')
    echo "${timestamp} [${level}] ${message}" >> "$LOG_FILE"
}

collect_metrics() {
    local cpu_used mem_total mem_available
    local mem_used_pct disk_used_pct top_procs

    cpu_used=$(awk '/^cpu / {idle=$5; total=$2+$3+$4+$5+$6+$7+$8; print int((total-idle)*100/total)}' /proc/stat)
    cpu_used=${cpu_used:-0}

    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    mem_used_pct=$(( (mem_total - mem_available) * 100 / mem_total ))

    disk_used_pct=$(df / | tail -1 | awk '{print $5}' | tr -d '%')

    top_procs=$(ps aux --sort=-%cpu \
      | awk 'NR==2,NR==4 {printf "%s(%.1f%%) ", $11, $3}')

    log_entry 'INFO' \
      "cpu=${cpu_used}% mem=${mem_used_pct}% disk=${disk_used_pct}% top=[${top_procs}]"
}

rotate_if_needed() {
    if [[ -f "$LOG_FILE" ]]; then
        local line_count
        line_count=$(wc -l < "$LOG_FILE")
        if (( line_count > MAX_LOG_LINES )); then
            tail -500 "$LOG_FILE" > "${LOG_FILE}.tmp"
            mv "${LOG_FILE}.tmp" "$LOG_FILE"
            log_entry 'INFO' 'Log rotated'
        fi
    fi
}

log_entry 'INFO' 'ServerWatch started'
while true; do
    collect_metrics
    rotate_if_needed
    sleep "$INTERVAL"
done
