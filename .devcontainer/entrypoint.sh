#!/bin/bash
source /usr/local/bin/logger.sh

sudo chown -R "$(whoami):$(whoami)" $HOME/.m2 2>/dev/null

log_notice "$0 Starting environment configuration..."

# 🧠 Funzione generica per controllare un array di variabili
check_required_vars() {
  local context=$1
  shift
  local missing=false

  for var in "$@"; do
    if [[ -z "${!var}" ]]; then
      log_warning "[$context] The variable $var is not set."
      missing=true
    fi
  done

  $missing && return 1 || return 0
}

# 🔍 Verifica variabili per GIT
GIT_VARS=(
    GIT_USERNAME
    GIT_EMAIL
    GIT_TOKEN
)

if check_required_vars "GIT" "${GIT_VARS[@]}"; then
  echo "I: [GIT] Configuring username and email..."
  git config --global user.name "$GIT_USERNAME"
  git config --global user.email "$GIT_EMAIL"
  git config --global credential.helper store
  echo "https://${GIT_USERNAME}:${GIT_TOKEN}@github.com" > ~/.git-credentials
else
  log_warning "[GIT] skipped configuration."
fi


NEXUS_VARS=(
    NEXUS_USER
    NEXUS_PASS
    NEXUS_HOST
    NEXUS_PORT
    NEXUS_TRUSTSTORE
    NEXUS_TRUSTSTORE_PASS
)

if check_required_vars "NEXUS" "${NEXUS_VARS[@]}"; then
  NEXUS_URL="${NEXUS_PROTOCOL}://${NEXUS_HOST}:${NEXUS_PORT}"
  log_info "[NEXUS] Variables are ready. Checking reachability of ${NEXUS_HOST}:${NEXUS_PORT}..."
  /usr/local/bin/configure-nexus-connection.sh \
    --host "$NEXUS_HOST" \
    --port "$NEXUS_PORT" \
    --truststore "$NEXUS_TRUSTSTORE" \
    --storepass "$NEXUS_TRUSTSTORE_PASS"
  
  /usr/local/bin/validate_maven_connection.sh
else
  log_notice "[NEXUS] Variabili mancanti. skipped"
fi


log_notice "STAYNG ALIVE..."
exec sleep infinity