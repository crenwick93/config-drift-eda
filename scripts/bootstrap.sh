#!/usr/bin/env bash
set -euo pipefail

# Bootstrap managed nodes: auditd, chronyd, Splunk UF + Cloud credentials.
# Sources the repo-root .env so all variables are centralized.
#
# Usage:
#   ./scripts/bootstrap.sh
#
# Required env (from top-level .env):
#   SPLUNK_UF_RPM, SPLUNK_CLOUD_CREDS_PACKAGE
# Optional:
#   SPLUNK_UF_ADMIN_PASSWORD (default: Splunk4ward!)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PLAYBOOK="${REPO_ROOT}/playbooks/bootstrap_node.yml"
INVENTORY="${REPO_ROOT}/inventory/hosts.yml"

if [[ -f "${REPO_ROOT}/.env" ]]; then
  echo "Loading environment from ${REPO_ROOT}/.env"
  set -a
  # shellcheck disable=SC1091
  source "${REPO_ROOT}/.env"
  set +a
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "Error: ansible-playbook not found. Install Ansible first."
  exit 1
fi

echo "Running bootstrap against inventory: ${INVENTORY}"
ansible-playbook "${PLAYBOOK}" -i "${INVENTORY}" "$@"
