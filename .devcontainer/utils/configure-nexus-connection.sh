#!/bin/bash
# configure-nexus-connection.sh - Detect protocol, check reachability, fetch cert and trust it
source /usr/local/bin/logger.sh
set -euo pipefail

# === Default values ===
HOST=""
PORT=""
TRUSTSTORE="${HOME}/.m2/truststore.p12"
STOREPASS="changeit"

# === Parse CLI arguments ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--host)
      HOST="$2"; shift 2;;
    -p|--port)
      PORT="$2"; shift 2;;
    -t|--truststore)
      TRUSTSTORE="$2"; shift 2;;
    -s|--storepass)
      STOREPASS="$2"; shift 2;;
    *)
      log_error "Unknown argument: $1"; exit 1;;
  esac
done

# === Validate input ===
if [[ -z "$HOST" || -z "$PORT" || -z "$TRUSTSTORE" ]]; then
  log_error "Usage: $0 --host <HOST> --port <PORT> --truststore <PATH> [--storepass <PASSWORD>]"
  exit 1
fi

# === Check reachability via HTTP and HTTPS ===
log_info "Checking reachability of $HOST:$PORT..."

if curl -sfL "http://$HOST:$PORT" --max-time 5 > /dev/null; then
  PROTOCOL="http"
  log_notice "Protocol detected: HTTP (reachable, no certificate trust needed)"
  exit 0
elif curl -sfLk "https://$HOST:$PORT" --max-time 5 > /dev/null; then
  PROTOCOL="https"
  log_notice "Protocol detected: HTTPS (reachable)"
else
  log_critical "Host $HOST:$PORT is not reachable via HTTP or HTTPS."
  exit 1
fi

# === HTTPS: Trust certificate ===
log_info "Fetching and trusting certificate from $HOST:$PORT..."
/usr/local/bin/fetch-and-trust-cert.sh \
  --host "$HOST" \
  --port "$PORT" \
  --truststore "$TRUSTSTORE" \
  --storepass "$STOREPASS"

log_info "Maven HTTPS trust setup completed."
