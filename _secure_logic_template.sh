#!/usr/bin/env bash 
# shellcheck disable=SC2065 #Disable warnings for redirecting instead comparing

# The usage of #!/usr/bin/env bash is recommended for portability
# and to ensure that the script runs with the user's default bash interpreter.

# Script Metadata
__secure_logic_version="1.0.0"
__secure_logic_date="$( date +%Y-%m-%d )"
__secure_logic_author="Rafael Mori"
__secure_logic_description="This script is a template for creating secure bash scripts."
__secure_logic_use_type="lib" # or "exec". lib if you want to use it as a library, exec if you want to run it as a standalone script.
__secure_logic_init_timestamp="$(date +%s)"
__secure_logic_elapsed_time=0

###################################################################################
# General Information:
# 
# All 'myname' prefixes must be replaced with your script reference. 
# For example, if your script is named 'grep_and_tail.sh',
# replace 'myname' with 'grep_and_tail' in all function names and variables.
# This ensures that the script is self-contained and does not interfere with other scripts.
# 
#################################################################################


# Check if verbose mode is enabled
if [[ "${MYNAME_VERBOSE:-false}" == "true" ]]; then
  set -x  # Enable debugging
fi


###################################################################################
# __secure_logic_sourced_name
#
# Generates a unique environment variable name based on the script name.
# This helps verify if the script was "sourced" correctly and prevents
# unwanted direct executions.
###################################################################################
__secure_logic_sourced_name() {
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
    local _ws_name="$(__secure_logic_sourced_name)"

    if test "${BASH_SOURCE-}" != "${0}"; then
      if test $__secure_logic_use_type != "lib"; then
        echo "This script is not intended to be sourced." 1>&2 > /dev/tty
        echo "Please run it directly." 1>&2 > /dev/tty
        exit 1
      fi
      # If the script is sourced, we set the variable to true
      # and export it to the environment without changing
      # the shell options.
      export "${_ws_name}"="true"
    else
      if test $__secure_logic_use_type != "exec"; then
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

###############################################################################
# sourced scripts dependencies (ex: logger.sh)
#
# Loads _simple_logger_template.sh only if the function log is not defined.
# This avoids multiple loads and conflicts.
#################################################################################
# shellcheck disable=SC2065,SC1091
test -z "$(declare -f log)" >/dev/null && source "$(dirname "${0}")/_simple_logger_template.sh"

#############################################################################
# __sec_logic_list_functions
#
# Exports only functions that **do not** start with '__', ensuring that
# internal functions are not accessed externally.
############################################################################
# shellcheck disable=SC2155
__secure_logic_list_functions() {
  local _str_functions=$(declare -F | awk '{print $3}' | grep -v "^__") >/dev/null || return 1
  # shellcheck disable=SC2116,SC2207
  declare -a _functions=( $(echo "$_str_functions") ) > /dev/null || return 1
  echo "${_functions[@]}"
  return 0
}

###############################################################################
# __secure_logic_main_functions
#
# Wraps the main functions to be executed. It will handle the execution of what
# is passed as an argument. It also exports the appropriate functions
# to the environment, ensuring they are available if the pourpose is to be
# sourced.
###############################################################################
__secure_logic_export_functions() {
  # shellcheck disable=SC2207
  local _exported_functions=( $(__secure_logic_list_functions) ) >/dev/null || return 1
  for _exported_function in "${_exported_functions[@]}"; do
    # shellcheck disable=SC2163
    export -f "${_exported_function}" >/dev/null || return 1
  done
  return 0
}
__secure_logic_exec_function() {
  local _func_name="${1:-}"
  shift
  if [[ -z "$_func_name" ]]; then
    log error "No function specified for execution."
    return 1
  fi
  if declare -F "$_func_name" >/dev/null 2>&1; then
    "$_func_name" "$@"
    return $?
  else
    log error "Function '$_func_name' not found."
    return 1
  fi
}

################################################################################
### BEGINNING OF SCRIPT LOGIC IN A SAFE ENVIRONMENT:
### NO ROOT, NO SUDO, NO EXPORTING UNNECESSARY VARIABLES

### Generalized example function for secure execution of any script/function
__secure_example_function () {
  if [[ $# -lt 2 ]]; then
    log error "Usage: $0 <script_path> <function_name> [args...]"
    return 1
  fi
  local _target_script="$1"
  local _target_function="$2"
  shift 2
  local _args=("$@")
  if [[ ! -f "${_target_script}" ]]; then
    log error "Target script '${_target_script}' does not exist."
    return 1
  fi
  "${_target_script}" "${_target_function}" "${_args[@]}"
  return $?
}

### END OF SCRIPT LOGIC, BELOW WE ENSURE ISOLATION
###############################################################################
# __sec_logic_main
#
# Main entry point of the script. Executes the function passed as an argument
# only after all validations and environment configurations.
###############################################################################
__secure_logic_main() {
  local _ws_name
  _ws_name="$(__secure_logic_sourced_name)"
  local _ws_name_val
  _ws_name_val=$(eval "echo \${$_ws_name}")
  if test "${_ws_name_val}" != "true"; then
    __secure_logic_exec_function "$@"
    exit $?
  else
    __secure_logic_export_functions
  fi
}

# All logic executed here if initial validation is successful
__secure_logic_main "$@"

#################################################################################
# # Set the elapsed time since the script started
# #
# # 
# # Profiling just with the elapsed time
# # This is a simple way to measure the elapsed time of the script
# # 
# # It is not a real profiling, but it can be useful to know how long
# # the script took to run. But ilustrates how to, in a simple way,
# # insert some ultra-basic, simple and superfluous profiling in the script
# # 
# # It is more for educational purposes than for real use.
# #
####################################################################################
__secure_logic_elapsed_time="$(($(date +%s) - __secure_logic_init_timestamp))"

######################################################################################
# # Print the elapsed time
# #
# # Will print the elapsed time (ONLY IF DEBUG OR VERBOSE IS ENABLED)
# #
##################################################################################
if [[ "${MYNAME_VERBOSE:-false}" == "true" || "${_DEBUG:-false}" == "true" ]]; then
  log info "Script executed in ${__secure_logic_elapsed_time} seconds."
fi

# End of script logic