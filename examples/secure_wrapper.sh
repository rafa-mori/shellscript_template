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
# Loads logger.sh only if the function kbx_log is not defined.
# This avoids multiple loads and conflicts.
#################################################################################
# shellcheck disable=SC2065,SC1091
test -z "$(declare -f kbx_log)" >/dev/null && source "$(realpath "$(dirname "${0}")")/utils/logger.sh" || return 1


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

  # Here we can add any additional checks or validations, inside the function
  # ensuring that will not be exported or visible outside of this function/scope.
  # This is a good place to add any additional checks or validations.
  # For example, we can check if the script is being run as root, if the
  # necessary directories and files exist, and if the environment is set up correctly.
  # Ex:
  # __check(){
  #   return 0
  #   # # Check if folders and files exist
  #   # local _current_hash=$(find "${_kbx_path_scripts}" -type f -exec md5sum {} + | md5sum | awk '{ print $1 }')
  #   # local _last_hash=$(cat "${_kbx_path_build}/logs/.hash")
  #   # local _git_hash=$(_ghh=$(git rev-parse HEAD) && curl -s "https://raw.githubusercontent.com/kubex-io/kubex/${_ghh}/support/scripts/.hash" 2>/dev/null || echo "0")
  #   # if test "${_current_hash}" != "${_last_hash}"; then
  #   #   echo "KUBEX: Please, run the script: ${_kbx_path_build}/logs/.hash" > /dev/tty
  #   #   exit 1 || kill -9 $$
  #   # fi

  #   # local _curl_hash_check=$(cat "${_kbx_path_utils}/curl_hash.txt" 2>/dev/null || echo "0")
  #   # if test "${_current_hash}" != "${_curl_hash_check}"; then
  #   #   echo "KUBEX: Please, run the script: ${_kbx_path_utils}/curl_hash.sh" > /dev/tty
  #   #   exit 1 || kill -9 $$
  #   # fi

  #   # if test -d "${_kbx_path_source}" && test -d "${_kbx_path_scripts}" && test -d "${_kbx_path_utils}"; then
  #   #   if test -f "${_kbx_path_source}/main.go" && test -f "${_kbx_path_scripts}/main.sh" && test -f "${_kbx_path_utils}/logger.sh"; then
  #   #     return 0
  #   #   else
  #   #     return 1
  #   #   fi
  #   # else
  #   #   return 1
  #   # fi
  # }

  if test $EUID && test $UID -eq 0; then
    kbx_log error "Please do not run as root."
    exit 1 || kill -9 $$
  elif test -n "${SUDO_USER:-}"; then
    kbx_log error "Please do not run as root, but with sudo privileges." > /dev/tty
    exit 1 || kill -9 $$
  else
    # Usage example of the internal function __check:
    # if ! __check; then
    #   kbx_log error "KUBEX: Please, this script is not meant to be sourced!" > /dev/tty
    #   exit 1 || kill -9 $$
    # else
      set -o errexit
      set -o nounset
      set -o pipefail
      set -o errtrace
      set -o functrace
      shopt -s inherit_errexit

      ##############################################################
      # # Exporting the variables to the environment
      # # 
      # # IT IS JUST A EXAMPLE, IT IS NOT REAL BECAUSE THE VARIABLES
      # # BUT EVEN THOUGH, THIS IS A GOOD EXAMPLE OF HOW TO EXPORT:
      # # READONLY AND JUST EXPORT THE VARIABLES THAT YOU WANT TO EXPORT
      # #
      ################################################################
      readonly _path_run=$(readlink -e "${0}") && export _path_run || return 1
      readonly _path_root="$(dirname "${_path_run}")" && export _path_root || return 1
      readonly _path_utils="${_path_root}/utils" && export _path_utils || return 1
      readonly _path_script_1="${_path_root}/example_1" && export _path_script_1 || return 1
      readonly _path_script_2="${_path_root}/example_2" && export _path_script_2 || return 1
      readonly _path_script_3="${_path_root}/example_3" && export _path_script_3 || return 1

      local _kbx_args=( "$@" )
      local _kbx_args_len="${#_kbx_args[@]}"
      if test "${_kbx_args_len}" -eq 0; then
        kbx_die 1 "No arguments provided."
      fi

      # # Example of how to handle a dynamic route based on the first argument
      # # to determine which script to run. This is a good example of how to
      # # handle the arguments and run the appropriate script.
      local _kbx_run_file=""
      _kbx_run_file="${_path_root}/example_${_kbx_args[0]}/other_script.sh"

      if test ! -f "${_kbx_run_file}"; then
        kbx_die 1 "The script ${_kbx_run_file} does not exist."
      fi

      # # List of functions prefixes to be used in the script
      local _functions_names=(
        "first"
        "second"
        "third"
      )


      local _run_cmd=()
      _run_cmd=(
        # Script to run
        "${_kbx_run_file}"

        # Function to run inside the script
        "${_functions_names[(( ${_kbx_args[0]} - 1 ))]}_function"

        # Arguments to pass to the script
        "${_kbx_args[@]:1:$_kbx_args_len}"
      )
      
      # Executing the command
      "${_run_cmd[@]}" || return 1

      # # Example of how to run the command with kbx_run, wrapped in a logging function
      #kbx_run info "${_run_cmd[@]}" || return 1
    fi
  #fi # end of the __check function if used
}


# Running the wrapper function with the arguments passed to the script
# and redirecting the output to /dev/tty.
__wrapper "$@" >/dev/tty

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
