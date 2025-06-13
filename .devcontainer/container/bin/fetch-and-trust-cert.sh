#!/bin/bash
source /usr/local/libexec/logger.sh
set -euo pipefail

# === Input ===
HOST="$1"
PORT="${2:-443}"
P12_PATH="${3:-truststore.p12}"
STOREPASS="${4:-changeit}"

# === Temp files ===
TMP_NEW_CERT=$(mktemp)
TMP_EXISTING_CERTS=$(mktemp)
TMP_EXISTING_PEM=$(mktemp)
trap 'rm -f "$TMP_NEW_CERT" "$TMP_EXISTING_CERTS" "$TMP_EXISTING_PEM"' EXIT

# === 1. Fetch new certificate ===
echo | openssl s_client -connect "$HOST:$PORT" -servername "$HOST" -showcerts 2>/dev/null |
  awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' > "$TMP_NEW_CERT"

if [[ ! -s "$TMP_NEW_CERT" ]]; then
  log_error "No certificate found from $HOST:$PORT" >&2
  exit 1
fi

# === 2. Compute fingerprint of the new cert ===
NEW_FP=$(openssl x509 -in "$TMP_NEW_CERT" -noout -fingerprint -sha256 | sed 's/.*=//;s/://g')

# === 3. Extract existing certs if the file exists ===
EXISTS=false
if [[ -f "$P12_PATH" ]]; then
  openssl pkcs12 -in "$P12_PATH" -out "$TMP_EXISTING_PEM" -nokeys -passin pass:"$STOREPASS" -passout pass:"$STOREPASS" 2>/dev/null || {
    log_error "Failed to read $P12_PATH" >&2
    exit 1
  }

  csplit -f "$TMP_EXISTING_CERTS" "$TMP_EXISTING_PEM" '/-----BEGIN CERTIFICATE-----/' '{*}' >/dev/null 2>&1

  for cert in "$TMP_EXISTING_CERTS"*; do
    [[ -s "$cert" ]] || continue
    FP=$(openssl x509 -in "$cert" -noout -fingerprint -sha256 2>/dev/null | sed 's/.*=//;s/://g' || true)
    if [[ "$FP" == "$NEW_FP" ]]; then
      log_info "Certificate already present in $P12_PATH (SHA256: $FP)"
      EXISTS=true
      break
    fi
  done
fi

# === 4. Append new cert if not duplicate ===
if [[ "$EXISTS" == false ]]; then
  log_info "Importing certificate into $P12_PATH (SHA256: $NEW_FP)"
  openssl pkcs12 -export \
    -in "$TMP_NEW_CERT" \
    -nokeys \
    -out "$P12_PATH" \
    -passout pass:"$STOREPASS" \
    -name "${HOST//[^a-zA-Z0-9]/_}_$(date +%s)"
    log_notice "Certificate imported successfully into $P12_PATH"
else
  log_notice "No import needed."
fi
