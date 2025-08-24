
#NEXUS_VARS=(
#    NEXUS_USER
#    NEXUS_PASS
#    NEXUS_HOST
#    NEXUS_PORT
#    NEXUS_TRUSTSTORE
#    NEXUS_TRUSTSTORE_PASS
#)
#
#if check_required_vars "NEXUS" "${NEXUS_VARS[@]}"; then
#  log_info "[NEXUS] Variables are ready. Checking reachability of ${NEXUS_HOST}:${NEXUS_PORT}..."
#  configure-nexus-connection.sh \
#    --host "$NEXUS_HOST" \
#    --port "$NEXUS_PORT" \
#    --truststore "$NEXUS_TRUSTSTORE" \
#    --storepass "$NEXUS_TRUSTSTORE_PASS"
#  
#  validate_maven_connection.sh
#else
#  log_notice "[NEXUS] Missing variables. skipped"
#fi
