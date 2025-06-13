#!/bin/bash
# validate_maven_connection.sh - Validate Maven connectivity and auth using mvn
source /usr/local/libexec/logger.sh
set -euo pipefail

SETTINGS_FILE="$HOME/.m2/settings.xml"

if [[ ! -f "$SETTINGS_FILE" ]]; then
  log_critical "Settings file not found: $SETTINGS_FILE"
  exit 1
fi

log_info "Using Maven settings: $SETTINGS_FILE"

# === Estrarre gli ID dei server definiti ===
SERVER_IDS=($(xmllint --xpath "//settings/servers/server/id/text()" "$SETTINGS_FILE" 2>/dev/null))

if [[ ${#SERVER_IDS[@]} -eq 0 ]]; then
  log_warning "No <server> IDs found in settings.xml."
else
  log_info "Checking authentication for ${#SERVER_IDS[@]} servers..."
  for ID in "${SERVER_IDS[@]}"; do
    log_info "Testing credentials for server ID: $ID"
    if mvn --batch-mode help:evaluate -Dexpression=project.name -DserverId="$ID" >/dev/null 2>&1; then
      log_notice "Authentication for '$ID' succeeded."
    else
      log_error "Authentication for '$ID' failed or the server is unreachable."
    fi
  done
fi


# === Download a small common jar from Nexus to test connectivity ===
COMMON_JAR="junit:junit:4.13.2"
log_info "Attempting to download a common jar ($COMMON_JAR) from Nexus..."
if mvn --batch-mode dependency:get -Dartifact=$COMMON_JAR >/dev/null 2>&1; then
    log_notice "Successfully downloaded $COMMON_JAR from Nexus."
else
    log_error "Failed to download $COMMON_JAR from Nexus."
fi
