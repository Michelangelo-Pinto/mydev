#!/bin/bash
source /usr/local/bin/logger.sh
set -e

TRUSTSTORE_PATH=""
TRUSTSTORE_PASS="changeIt"

usage() {
  cat <<EOF
Usage: $(basename "$0") -f <path> [-p <password>] [-h]

Creates a new empty PKCS12 truststore at the specified path, or skips if the file already exists.

Options:
  -f <path>      Path to the truststore file (required)
  -p <password>  Password for the truststore (default: changeIt)
  -h             Show this help message

Example:
  $(basename "$0") -f /etc/ssl/my-truststore.p12 -p mySecret
EOF
}

# Parse CLI args
while getopts ":f:p:h" opt; do
  case ${opt} in
    f )
      TRUSTSTORE_PATH="$OPTARG"
      ;;
    p )
      TRUSTSTORE_PASS="$OPTARG"
      ;;
    h )
      usage
      exit 0
      ;;
    \? )
      log_error "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    : )
      log_error "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

# Validate required argument
if [[ -z "$TRUSTSTORE_PATH" ]]; then
  log_error "Truststore path (-f) is required." >&2
  usage
  exit 1
fi

log_info "Target truststore path: $TRUSTSTORE_PATH"
mkdir -p "$(dirname "$TRUSTSTORE_PATH")"

if [[ -f "$TRUSTSTORE_PATH" ]]; then
  log_notice "Truststore already exists. Skipping creation."
  exit 0
fi

# Create the truststore with a temporary key entry
keytool -genkeypair \
  -alias __temp__ \
  -keystore "$TRUSTSTORE_PATH" \
  -storetype PKCS12 \
  -storepass "$TRUSTSTORE_PASS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 1 \
  -dname "CN=temp" >/dev/null 2>&1

# Delete the placeholder key
keytool -delete \
  -alias __temp__ \
  -keystore "$TRUSTSTORE_PATH" \
  -storepass "$TRUSTSTORE_PASS" >/dev/null 2>&1

log_notice "Empty PKCS12 truststore created at: $TRUSTSTORE_PATH"
