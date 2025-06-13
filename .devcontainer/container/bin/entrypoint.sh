#!/bin/bash
set -euo pipefail

source /usr/local/libexec/logger.sh
source /usr/local/libexec/utils.sh

HOOK_DIR="/entrypoint.d"
EXEC_FOUND=0

log_info "Starting entrypoint execution..."

for script in "$HOOK_DIR"/[0-9][0-9]*.sh; do
  if [[ -f "$script" && -x "$script" ]]; then
    log_info "Executing hook: $(basename "$script")"
    if [[ "$(basename "$script")" =~ ^99-.*\.sh$ ]]; then
      EXEC_FOUND=1
    fi
    source "$script"
  else
    log_warning "Skipping non-executable or missing script: $script"
  fi
done

if [[ "$EXEC_FOUND" -eq 0 ]]; then
  log_critical "No main executable found (99-*.sh). Exiting."
  exit 127
fi

log_error "Unexpected return after main exec (should never return)."
exit 1
