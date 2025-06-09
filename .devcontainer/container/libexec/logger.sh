# ==============================================================================
# File:         logger.sh
# Description:  Structured logging functions for Bash scripts with syslog levels.
#               Designed to be sourced in other scripts.
#
# Author:       Michelangelo Pinto
# Version:      1.0.0
# License:      SPDX-License-Identifier: CC-BY-NC-4.0 OR LicenseRef-commercial
# ==============================================================================
#
# Usage:
#   source /usr/local/bin/logger.sh
#
#   log_info "Starting process..."
#   log_error "Something failed"
#
# Supported LOG_LEVEL values (from most critical to least):
#   EMERGENCY - System is unusable
#   ALERT     - Immediate action required
#   CRITICAL  - Critical conditions
#   ERROR     - Error conditions
#   WARNING   - Warning conditions
#   NOTICE    - Significant normal condition
#   INFO      - Informational messages (default)
#   DEBUG     - Verbose debug messages
#   XDEBUG    - Bash tracing with PS4 (overrides all log functions with no-ops)
#
# Environment variables:
#   LOG_LEVEL  Controls minimum log level shown (default: INFO)
#
# Example:
#   export LOG_LEVEL=WARNING
#   source logger.sh
#   log_info "Will not print"
#   log_error "Will print"
#
# Requirements:
#   - Bash 4.x+ (associative array support)
#
# Notes:
#   - Timestamps are UTC ISO 8601
#   - Script name is automatically prepended in log output
#   - XDEBUG enables `set -x` with contextual PS4 and disables all log functions
#   - Script should be sourced, not executed directly
# ==============================================================================

__load_logger_sh() {
  # Singleton guard
  if declare -F log_info >/dev/null; then
    return 0
  fi

  # Mapping of log level names to syslog severity values
  declare -gA LOG_LEVELS=(
    [EMERGENCY]=0
    [ALERT]=1
    [CRITICAL]=2
    [ERROR]=3
    [WARNING]=4
    [NOTICE]=5
    [INFO]=6
    [DEBUG]=7
  )

  # Set default log level
  export LOG_LEVEL="${LOG_LEVEL:-INFO}"
  local LOG_LEVEL_NUM=${LOG_LEVELS[$LOG_LEVEL]:-6}  # Default to INFO

  if [[ "$LOG_LEVEL" == "XDEBUG" ]]; then
    export PS4='[DEBUG] $(date -u +%Y-%m-%dT%H:%M:%SZ) [${BASH_SOURCE##*/}:${LINENO}] ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
    set -x
    # Override all log functions to no-op
    log_emergency() { :; }
    log_alert()     { :; }
    log_critical()  { :; }
    log_error()     { :; }
    log_warning()   { :; }
    log_notice()    { :; }
    log_info()      { :; }
    log_debug()     { :; }
    return
  fi

  _log_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
  }

  _log() {
    local level="$1"; shift
    local message="$*"
    local level_num=${LOG_LEVELS[$level]:-6}
    [[ $level_num -gt ${LOG_LEVELS[$LOG_LEVEL]:-6} ]] && return 0

    local timestamp=$(_log_timestamp)
    local script_name=$(basename "${BASH_SOURCE[-1]}")
    local formatted="[$level] $timestamp [$script_name] $message"

    if [[ $level_num -le 3 ]]; then
      echo "$formatted" >&2
    else
      echo "$formatted"
    fi
  }

  # Log functions (exported globally)
  declare -f log_emergency >/dev/null || log_emergency() { _log EMERGENCY "$@"; }
  declare -f log_alert     >/dev/null || log_alert()     { _log ALERT     "$@"; }
  declare -f log_critical  >/dev/null || log_critical()  { _log CRITICAL  "$@"; }
  declare -f log_error     >/dev/null || log_error()     { _log ERROR     "$@"; }
  declare -f log_warning   >/dev/null || log_warning()   { _log WARNING   "$@"; }
  declare -f log_notice    >/dev/null || log_notice()    { _log NOTICE    "$@"; }
  declare -f log_info      >/dev/null || log_info()      { _log INFO      "$@"; }
  declare -f log_debug     >/dev/null || log_debug()     { _log DEBUG     "$@"; }
}

# Invoke singleton loader
__load_logger_sh
