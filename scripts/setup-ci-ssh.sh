#!/usr/bin/env bash
set +x
set -euo pipefail
: "${CI_SSH_KEY_BASE64:?Missing private-input SSH key}"
: "${GITHUB_ENV:?Missing GitHub Actions environment file}"
eval "$(ssh-agent -s)" >/dev/null
trap 'ssh-agent -k >/dev/null 2>&1 || true' ERR
# Keep decoded key material out of files, outputs and subsequent step environments.
printf '%s' "$CI_SSH_KEY_BASE64" | base64 --decode | ssh-add -q -
printf 'SSH_AUTH_SOCK=%s\nSSH_AGENT_PID=%s\n' "$SSH_AUTH_SOCK" "$SSH_AGENT_PID" >> "$GITHUB_ENV"
