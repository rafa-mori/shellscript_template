#!/usr/bin/env bash


###################################################################################
# General Information:
#
# This script is a wrapper example that can be used with the secure_template.sh 
# template. It is a illustration of how you can basically secure your script
# and make it more robust. It is not meant to be used as is, but as a reference
# for you to create your own wrapper script. Below you can find some suggestions
# and examples of how you can try to secure your entry points or wrapper scripts.
#
###############################################################################


###############################################################################
# sourced scripts dependencies (ex: logger.sh)
#
# Loads _simple_logger_template.sh only if the function log is not defined.
# This avoids multiple loads and conflicts.
#################################################################################
# shellcheck disable=SC2065,SC1091
test -z "$(declare -f log)" >/dev/null && source "$(realpath "$(dirname "${0}")")/_simple_logger_template.sh" || return 1


###############################################################################
# __wrapper
#
# This is a wrapper script to run the kubex modules installation,
# building, uninstalling, cleaning and testing. It is not meant to be run
# directly to avoid any issues and protect the environment and the user.
# It is meant to be run by the Makefile or other scripts. 
#
###############################################################################
# shellcheck disable=SC2317,SC2155
__wrapper(){
  # Generalized secure wrapper logic for any script
  # Add your own checks and environment setup here

  # Example: Prevent running as root
  if [[ $EUID -eq 0 || $UID -eq 0 ]]; then
    log error "Do not run this script as root."
    exit 1
  elif [[ -n "${SUDO_USER:-}" ]]; then
    log error "Do not run this script with sudo privileges."
    exit 1
  fi

  set -o errexit
  set -o nounset
  set -o pipefail
  set -o errtrace
  set -o functrace
  shopt -s inherit_errexit

  # Example: Export only the variables you want to expose
  readonly _path_run=$(readlink -e "${0}") && export _path_run || return 1
  readonly _path_root="$(dirname "${_path_run}")" && export _path_root || return 1
  readonly _path_utils="${_path_root}/utils" && export _path_utils || return 1

  # Accepts: script path, function name, and any arguments
  if [[ $# -lt 2 ]]; then
    log error "Usage: $0 <script_path> <function_name> [args...]"
    exit 1
  fi
  local _target_script="$1"
  local _target_function="$2"
  shift 2
  local _args=("$@")

  if [[ ! -f "${_target_script}" ]]; then
    log error "Target script '${_target_script}' does not exist."
    exit 1
  fi

  # Call the target script with the function and arguments
  "${_target_script}" "${_target_function}" "${_args[@]}"
}

# Run the wrapper with all arguments
__wrapper "$@" >/dev/tty
