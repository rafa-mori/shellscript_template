#!/usr/bin/env bash

###################################################################################
# General Information:
# 
# All 'myname' prefixes must be replaced with your script reference. 
# For example, if your script is named 'grep_and_tail.sh',
# replace 'myname' with 'grep_and_tail' in all function names and variables.
# This ensures that the script is self-contained and does not interfere with other scripts.
# 
#################################################################################

__other_script_version="1.0.0"
__other_script_date="$( date +%Y-%m-%d )"
__other_script_author="Rafael Mori"
__other_script_description="This script is a template for creating secure bash scripts."
__other_script_use_type="lib" # or "exec". lib if you want to use it as a library, exec if you want to run it as a standalone script.

if [[ "${MYNAME_VERBOSE:-false}" == "true" ]]; then
  set -x  # Enable debugging
fi

###################################################################################
# __other_script_sourced_name
#
# Generates a unique environment variable name based on the script name.
# This helps verify if the script was "sourced" correctly and prevents
# unwanted direct executions.
###################################################################################
__other_script_sourced_name() {
  local _self="${BASH_SOURCE-}"
  _self="${_self//${_kbx_root:-$()}/}"
  _self="${_self//\.sh/}"
  _self="${_self//\-/_}"
  _self="${_self//\//_}"
  echo "_was_sourced_${_self//__/_}"
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
    local _ws_name="$(__other_script_sourced_name)"

    if test "${BASH_SOURCE-}" != "${0}"; then
      if test $__other_script_use_type != "lib"; then
        echo "This script is not intended to be sourced." 1>&2 > /dev/tty
        echo "Please run it directly." 1>&2 > /dev/tty
        exit 1
      fi
      # If the script is sourced, we set the variable to true
      # and export it to the environment without changing
      # the shell options.
      export "${_ws_name}"="true"
    else
      if test $__other_script_use_type != "exec"; then
        echo "This script is not intended to be executed directly." 1>&2 > /dev/tty
        echo "Please source it instead." 1>&2 > /dev/tty
        exit 1
      fi
      # If the script is executed directly, we set the variable to false
      # and export it to the environment. We also set the shell options
      # to ensure a safe execution.
      export "${_ws_name}"="false"
      set -o errexit # Exit immediately if a command exits with a non-zero status
      set -o nounset # Treat unset variables as an error when substituting
      set -o pipefail # Return the exit status of the last command in the pipeline that failed
      set -o errtrace # If a command fails, the shell will exit immediately
      set -o functrace # If a function fails, the shell will exit immediately
      shopt -s inherit_errexit # Inherit the errexit option in functions
    fi
  fi
}
__first "$@" >/dev/tty || exit 1

#################################################################################
# sourced scripts dependencies (ex: logger.sh)
#
# Loads logger.sh only if the function kbx_log is not defined.
# This avoids multiple loads and conflicts.
#################################################################################
# shellcheck disable=SC2065,SC1091
test -z "$(declare -f kbx_log)" >/dev/null && source "${_path_utils:-"$(dirname "${0}")"}/logger.sh"

#############################################################################
# __other_script_list_functions
#
# Exports only functions that **do not** start with '__', ensuring that
# internal functions are not accessed externally.
############################################################################
# shellcheck disable=SC2155
__other_script_list_functions() {
  local _str_functions=$(declare -F | awk '{print $3}' | grep -v "^__") >/dev/null || return 1
  # shellcheck disable=SC2116,SC2207
  declare -a _functions=( $(echo "$_str_functions") ) > /dev/null || return 1
  echo "${_functions[@]}"
  return 0
}

###############################################################################
# __other_script_main_functions
#
# Wraps the main functions to be executed. It will handle the execution of what
# is passed as an argument. It also exports the appropriate functions
# to the environment, ensuring they are available if the pourpose is to be
# sourced.
###############################################################################
__other_script_export_functions() {
  # shellcheck disable=SC2207
  local _exported_functions=( $(__other_script_list_functions) ) >/dev/null || return 1
  for _exported_function in "${_exported_functions[@]}"; do
    # shellcheck disable=SC2163
    export -f "${_exported_function}" >/dev/null || return 1
  done
  return 0
}
__other_script_exec_function() {
  local _func_name="${1:-}"  # Sempre captura o primeiro argumento como nome da função
  shift                      # Remove o primeiro argumento para que $@ contenha apenas os parâmetros

  if [[ -z "$_func_name" ]]; then
    echo "Erro: Nenhuma função foi especificada para execução." 1>&2
    return 1
  fi

  if declare -F "$_func_name" >/dev/null 2>&1; then
    "$_func_name" "$@"  # Executa a função com os argumentos restantes
    return $?
  else
    if declare -F kbx_log >/dev/null 2>&1; then
      kbx_log error "Função '$_func_name' não encontrada."
    else
      echo "Erro: Função '$_func_name' não encontrada." 1>&2
    fi
    return 1
  fi
}

################################################################################
### BEGINNING OF SCRIPT LOGIC IN A SAFE ENVIRONMENT:
### NO ROOT, NO SUDO, NO EXPORTING UNNECESSARY VARIABLES

third_function() {
  # This function is just an example. You can replace it with your own logic.
  echo "This is the third function."
}

### END OF SCRIPT LOGIC, BELOW WE ENSURE ISOLATION
###############################################################################
# __other_script_main
#
# Main entry point of the script. Executes the function passed as an argument
# only after all validations and environment configurations.
###############################################################################
__other_script_main() {
  # shellcheck disable=SC2155
  local _ws_name="$(__other_script_sourced_name)"
  eval "local _ws_name=\$${_ws_name}" >/dev/null

  # shellcheck disable=SC2116
  if test "$(echo "${_ws_name}")" != "true"; then # If the script is not sourced
    __other_script_exec_function "$@"
    exit $?
  else
    __other_script_export_functions
  fi
}

# All logic executed here if initial validation is successful
__other_script_main "$@"
