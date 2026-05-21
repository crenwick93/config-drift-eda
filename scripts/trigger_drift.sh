#!/bin/bash
# Simulates a Splunk webhook firing a config drift event to EDA.
# Usage: ./scripts/trigger_drift.sh [hostname]

set -a
source "$(dirname "$0")/../.env"
set +a

HOST="${1:-rhel-drift.sandbox2797.opentlc.com}"
CHANGED_FILE="${2:-/etc/ssh/sshd_config}"
EDA_USER="${EDA_EVENT_STREAM_USER:-splunk}"
EDA_PASS="${EDA_EVENT_STREAM_PASS:-${SPLUNK_WEBHOOK_TOKEN:-changeme}}"
EDA_URL="${EDA_EVENT_STREAM_URL}"

if [ -z "$EDA_URL" ]; then
  echo "ERROR: EDA_EVENT_STREAM_URL not set in .env"
  exit 1
fi

echo "Firing config drift event to EDA..."
echo "  Host:     $HOST"
echo "  Endpoint: $EDA_URL"
echo ""

RESPONSE=$(curl -sk -w "\nHTTP_CODE:%{http_code}" \
  -u "${EDA_USER}:${EDA_PASS}" \
  -H "Content-Type: application/json" \
  -d "{
    \"result\": {
      \"host\": \"${HOST}\",
      \"drift_key\": \"config_drift\",
      \"auid\": \"1000\",
      \"name\": \"${CHANGED_FILE}\"
    },
    \"sid\": \"trigger-$(date +%s)\",
    \"results_link\": \"\"
  }" \
  "${EDA_URL}" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | tail -1 | sed 's/HTTP_CODE://')
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
  echo "OK — Event sent (HTTP $HTTP_CODE)"
else
  echo "FAILED — HTTP $HTTP_CODE"
  echo "$BODY"
fi
