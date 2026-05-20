#!/usr/bin/env bash
set -euo pipefail

# Apply AAP Controller + EDA objects for the config-drift demo.
# Sources the repo-root .env so all variables are centralized.
#
# Usage:
#   ./ansible_deployment/scripts/cac-apply.sh
#
# Required env (from top-level .env):
#   AAP_BASE_URL, AAP_API_CLIENT_BEARER_TOKEN
# Optional:
#   AAP_VALIDATE_CERTS, SPLUNK_HEC_URL, SPLUNK_HEC_TOKEN,
#   SERVICENOW_INSTANCE_URL, SERVICENOW_USERNAME, SERVICENOW_PASSWORD,
#   CONFIG_BASELINE_REPO_URL, MANAGED_NODE_SSH_KEY, WEBHOOK_DE_IMAGE

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLAYBOOK="${REPO_ROOT}/ansible_deployment/cac/apply.yml"

if [[ -f "${REPO_ROOT}/.env" ]]; then
  echo "Loading environment from ${REPO_ROOT}/.env"
  # shellcheck disable=SC2046
  export $(grep -v '^#' "${REPO_ROOT}/.env" | grep -v '^\s*$' | xargs -I{} echo {})
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "Error: ansible-playbook not found. Install Ansible first."
  exit 1
fi

ansible-playbook "${PLAYBOOK}" "$@"
