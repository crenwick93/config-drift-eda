#!/bin/bash
# Checks for recent config_drift audit events and writes a JSON summary
# to a log file that Splunk UF monitors. One line per unique file.

LOG=/var/log/drift_summary.log
STATE=/var/run/drift_summary_last
NOW=$(date +%s)

if [ -f "$STATE" ]; then
  SINCE=$(cat "$STATE")
else
  SINCE=$((NOW - 120))
fi
echo "$NOW" > "$STATE"

declare -A SEEN

sudo grep "config_drift" /var/log/audit/audit.log | grep 'type=SYSCALL' | while read line; do
  EPOCH=$(echo "$line" | grep -oP 'audit\(\K[0-9]+')
  [ -z "$EPOCH" ] && continue
  [ "$EPOCH" -lt "$SINCE" ] && continue

  AUID=$(echo "$line" | grep -oP 'auid=\K[0-9]+')
  EXE=$(echo "$line" | grep -oP 'exe="\K[^"]+')
  COMM=$(echo "$line" | grep -oP 'comm="\K[^"]+')
  EVENTID=$(echo "$line" | grep -oP 'audit\([0-9.]+:\K[0-9]+')

  FILEPATH=$(sudo grep "msg=audit.*:${EVENTID})" /var/log/audit/audit.log \
    | grep 'type=PATH' \
    | grep -oP 'name="\K[^"]+' \
    | grep -E '(sshd_config|chrony\.conf|sudoers|pam\.d/.+)$' \
    | head -1)

  [ -z "$FILEPATH" ] && continue
  [ -n "${SEEN[$FILEPATH]}" ] && continue
  SEEN[$FILEPATH]=1

  echo "{\"drift_key\":\"config_drift\",\"changed_file\":\"${FILEPATH}\",\"auid\":\"${AUID}\",\"exe\":\"${EXE}\",\"comm\":\"${COMM}\",\"host\":\"$(hostname -f)\"}" >> "$LOG"
done
