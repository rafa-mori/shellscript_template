#!/bin/bash

# AGPL-3.0-or-later License
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

# ###################################################################################
# # General Information:
# #
# # This is a simple logger for bash scripts.
# # It provides functions to log messages with different severity levels.
# # The logger uses ANSI escape codes to color the output, making it easier to read.
# # It also provides a way to use a global debug variable to control the logging output, or 
# # a local debug variable to control the logging output for a specific commands or any logics independently.
# #
# # The logger is designed to be used in bash scripts and can be sourced or executed.
# #
# # The logger provides the following functions:
# #   - log: Logs a message with a specific severity level (info, warn, error, success).
# #
########################################################################################

set -o errexit # Exit immediately if a command exits with a non-zero status
set -o pipefail # Return the exit status of the last command in the pipeline that failed
set -o errtrace # If a command fails, the shell will exit immediately
set -o functrace # If a function fails, the shell will exit immediately
shopt -s inherit_errexit # Inherit the errexit option in functions


# ###################################################################################
# # Global Variables:
# #
# # Below are the global variables used in the logger for coloring the output.
# # These variables are used to define the colors for different log levels.
# # The colors are defined using ANSI escape codes.
# # 
####################################################################################
_SUCCESS="\033[0;32m"
_WARN="\033[0;33m"
_ERROR="\033[0;31m"
_INFO="\033[0;36m"
_NC="\033[0m"


##############################################################################
# # Function: log
# #
# # This function logs messages with different severity levels.
# # It uses ANSI escape codes to color the output.
# # The function takes three arguments, beeing only the first two mandatory.
# # 
# # Arguments:
# #   $1 - log level (info|INFO|i|I, warn|WARN|w|W, error|ERROR|e|E, success|SUCCESS|s|S)
# #   $2 - message to log
# #   $3 - debug flag (optional, default: false)
# #
# # Usage/Example:
# #   log "INFO" "This is an info message"
# #   log "info" "This is an info message"
# #   log "i" "This is an info message"
# #
# #   log "WARN" "This is a warning message"
# #   log "warn" "This is a warning message"
# #   log "w" "This is a warning message"
# #
# #   log "ERROR" "This is an error message"
# #   log "error" "This is an error message"
# #   log "e" "This is an error message"
# #
# #   log "SUCCESS" "This is a success message"
# #   log "success" "This is a success message"
# #   log "s" "This is a success message"
# #
#############################################################################
log() {
  local type=
  type=${1:-info}
  local message=
  message=${2:-}
  local debug=${3:-${_DEBUG:-false}}

  # With colors
  case $type in
    info|_INFO|-i|-I)
      if [[ "$debug" == true ]]; then
        printf '%b[_INFO]%b ℹ️  %s\n' "$_INFO" "$_NC" "$message"
      fi
      ;;
    warn|_WARN|-w|-W)
      if [[ "$debug" == true ]]; then
        printf '%b[_WARN]%b ⚠️  %s\n' "$_WARN" "$_NC" "$message"
      fi
      ;;
    error|_ERROR|-e|-E)
      printf '%b[_ERROR]%b ❌  %s\n' "$_ERROR" "$_NC" "$message"
      ;;
    success|_SUCCESS|-s|-S)
      printf '%b[_SUCCESS]%b ✅  %s\n' "$_SUCCESS" "$_NC" "$message"
      ;;
    *)
      if [[ "$debug" == true ]]; then
        kbx_log "info" "$message"
      fi
      ;;
  esac
}

# end of script