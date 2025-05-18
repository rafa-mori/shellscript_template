#!/usr/bin/env bash

# MIT License
#
# Copyright (C) 2025 Rafael Mori
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Inspired by Adrelanos' helper-scripts (https://github.com/Whonix/helper-scripts)
#
# SPDX-License-Identifier: AGPL-3.0-or-later

###################################################################################
# __myname_sourced_name
#
# Generates a unique environment variable name based on the script name.
# This helps verify if the script was "sourced" correctly and prevents
# unwanted direct executions.
###################################################################################
__myname_sourced_name() {
  local _self="${BASH_SOURCE-}"
  _self="${_self//${_kbx_root:-$()}/}"
  _self="${_self//\.sh/}"
  _self="${_self//\-/_}"
  _self="${_self//\//_}"
  echo "_was_sourced_${_self//__/_}"
  return 0
}

###############################################################################
# sourced scripts dependencies (ex: logger.sh)
#
# Loads logger.sh only if the function kbx_log is not defined.
# This avoids multiple loads and conflicts.
#################################################################################
# shellcheck disable=SC2065,SC1091
test -z "$(declare -f kbx_log)" >/dev/null && source "${_kbx_path_helpers:-"$(dirname "${0}")"}/logger.sh"

#############################################################################
# __myname_list_functions
#
# Exports only functions that **do not** start with '__', ensuring that
# internal functions are not accessed externally.
############################################################################
# shellcheck disable=SC2155
__myname_list_functions() {
  local _str_functions=$(declare -F | awk '{print $3}' | grep -v "^__") >/dev/null || return 1
  # shellcheck disable=SC2116,SC2207
  declare -a _functions=( $(echo "$_str_functions") ) > /dev/null || return 1
  echo "${_functions[@]}"
  return 0
}

###############################################################################
# __myname_main_functions
#
# Wraps the main functions to be executed. It will handle the execution of what
# is passed as an argument. It also exports the appropriate functions
# to the environment, ensuring they are available if the pourpose is to be
# sourced.
###############################################################################
__myname_main_functions() {
  # shellcheck disable=SC2207
  local _exported_functions=( $(__myname_list_functions) ) >/dev/null || return 1
  for _exported_function in "${_exported_functions[@]}"; do
    # shellcheck disable=SC2163
    export -f "${_exported_function}" >/dev/null || return 61
  done
  return 0
}

###############################################################################
# __first
#
# Initial script validation. Ensures it is not executed as root
# and configures shell options for safe execution.
#################################################################################
__first(){
  if [ "$EUID" -eq 0 ] || [ "$UID" -eq 0 ]; then
    echo "Please do not run as root." 1>&2 > /dev/tty
    exit 1
  elif [ -n "${SUDO_USER:-}" ]; then
    echo "Please do not run as root, but with sudo privileges." 1>&2 > /dev/tty
    exit 1
  else
    # shellcheck disable=SC2155
    local _ws_name="$(__myname_sourced_name)"
    if test "${BASH_SOURCE-}" != "${0}"; then
      export "${_ws_name}"="true"
    else
      export "${_ws_name}"="false"
      set -o errexit
      set -o nounset
      set -o pipefail
      set -o errtrace
      set -o functrace
      shopt -s inherit_errexit
    fi
  fi
}
__first "$@" >/dev/tty || exit 1

################################################################################
### BEGINNING OF SCRIPT LOGIC IN A SAFE ENVIRONMENT:
### NO ROOT, NO SUDO, NO EXPORTING UNNECESSARY VARIABLES

# ALL LOGIC WRITTEN HERE WILL BE EXECUTED IN A SAFE, CONTROLLED AND WRAPPED ENVIRONMENT

### END OF SCRIPT LOGIC, BELOW WE ENSURE ISOLATION
###############################################################################
# __myname_main
#
# Main entry point of the script. Executes the function passed as an argument
# only after all validations and environment configurations.
###############################################################################
__myname_main() {
  # shellcheck disable=SC2155
  local _ws_name="$(__myname_sourced_name)"
  eval "local _ws_name=\$${_ws_name}" >/dev/null

  # shellcheck disable=SC2116
  if test "$(echo "${_ws_name}")" != "true"; then
    __myname_main_functions "$@"
    exit $?
  else
    printf "The script cannot be executed directly.\n" 1>&2 > /dev/tty
    exit 1
  fi
}

# All logic executed here if initial validation is successful
__myname_main "$@"
