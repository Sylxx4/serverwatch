#!/bin/bash
set -euo pipefail
REMOTE_HOST='serverwatch-local'
REMOTE_LOG='/var/log/serverwatch/health.log'
LINES=${1:-20}

echo "=== ServerWatch -- last ${LINES} entries ==="
ssh "$REMOTE_HOST" "tail -${LINES} ${REMOTE_LOG}"
