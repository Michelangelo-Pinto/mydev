#!/bin/bash
# ==============================================================================
# File:         utils.sh
# Description:  Common reusable Bash functions for devops scripts.
# Author:       Michelangelo Pinto
# ==============================================================================

check_required_vars() {
  local context=$1
  shift
  local missing=false

  if [[ $# -lt 2 ]]; then
      echo "Usage: check_required_vars <context> <message> [<message> ...]"
      exit 1
  fi

  for var in "$@"; do
    if [[ -z "${!var:-}" ]]; 
      log_warning "[$context] The variable $var is not set."
      missing=true
    fi
    if [[ -n "${!var+x}" && -z "${!var}" ]]; then
      log_warning "[$context] The variable $var is set but empty."
    fi
  done

  $missing && return 1 || return 0
}
