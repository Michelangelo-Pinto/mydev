#!/bin/bash
source /usr/local/bin/log.sh
set -euo pipefail

# === Default values ===
HOST=""
PORT=""
TRUSTSTORE=""
STOREPASS="changeIt"

# === Temporary files ===
TMP_CHAIN=$(mktemp)
TMP_CERTS_DIR=$(mktemp -d)
TMP_ROOT=$(mktemp)
TMP_EXPORT=$(mktemp)
trap 'rm -f "$TMP_CHAIN" "$TMP_ROOT" "$TMP_EXPORT"; rm -rf "$TMP_CERTS_DIR"' EXIT

# === Parse CLI arguments ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--host)
      HOST="$2"
      shift 2
      ;;
    -p|--port)
      PORT="$2"
      shift 2
      ;;
    -t|--truststore)
      TRUSTSTORE="$2"
      shift 2
      ;;
    -s|--storepass)
      STOREPASS="$2"
      shift 2
      ;;
    *)
      log_error "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# === Validate arguments ===
if [[ -z "$HOST" || -z "$PORT" || -z "$TRUSTSTORE" ]]; then
  log_error "Usage: $0 --host <HOST> --port <PORT> --truststore <PATH> [--storepass <PASSWORD>]"
  exit 1
fi

log_info "Fetching certificate chain from $HOST:$PORT..."

# === Fetch the certificate chain ===
if ! echo | openssl s_client -connect "$HOST:$PORT" -showcerts -servername "$HOST" > "$TMP_CHAIN" 2>/dev/null; then
  log_error "Failed to connect to $HOST:$PORT or retrieve certificates."
  exit 1
fi

# === Extract PEM certificates ===
awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' "$TMP_CHAIN" > "$TMP_ROOT"

if ! grep -q "BEGIN CERTIFICATE" "$TMP_ROOT"; then
  log_error "No PEM certificate found in server response."
  exit 1
fi

# === Compute fingerprint ===
CERT_FP=$(openssl x509 -in "$TMP_ROOT" -noout -fingerprint -sha256 | sed 's/.*=//;s/://g')
if [[ -z "$CERT_FP" ]]; then
  log_error "Failed to compute certificate fingerprint."
  exit 1
fi

# === Prepare truststore ===
if [[ ! -f "$TRUSTSTORE" ]]; then
  log_info "I:  Creating new truststore at $TRUSTSTORE..."
  keytool -importcert \
    -alias init_temp \
    -file "$TMP_ROOT" \
    -keystore "$TRUSTSTORE" \
    -storepass "$STOREPASS" \
    -storetype PKCS12 \
    -noprompt >/dev/null 2>&1
  keytool -delete -alias init_temp -keystore "$TRUSTSTORE" -storepass "$STOREPASS" >/dev/null 2>&1
fi

# === Check for existing certificate (by fingerprint) ===
log_info "Scanning truststore for duplicate certificate..."

DUPLICATE_FOUND=false
for ALIAS in $(keytool -list -keystore "$TRUSTSTORE" -storepass "$STOREPASS" 2>/dev/null | grep -E '^\S' | cut -d',' -f1); do
  if keytool -exportcert -alias "$ALIAS" -keystore "$TRUSTSTORE" -storepass "$STOREPASS" -rfc > "$TMP_EXPORT" 2>/dev/null; then
    EXISTING_FP=$(openssl x509 -in "$TMP_EXPORT" -noout -fingerprint -sha256 | sed 's/.*=//;s/://g')
    if [[ "$EXISTING_FP" == "$CERT_FP" ]]; then
      log_notice "Certificate already exists in truststore (alias: $ALIAS). Skipping import."
      DUPLICATE_FOUND=true
      break
    fi
  fi
done

if $DUPLICATE_FOUND; then
  exit 0
fi

# === Import certificate ===
ALIAS="${HOST//[^a-zA-Z0-9]/_}_$(date +%s)"
log_info "Importing certificate as alias '$ALIAS'..."
keytool -importcert \
  -alias "$ALIAS" \
  -file "$TMP_ROOT" \
  -keystore "$TRUSTSTORE" \
  -storepass "$STOREPASS" \
  -storetype PKCS12 \
  -noprompt

log_notice "Certificate imported successfully (SHA256: $CERT_FP)"
