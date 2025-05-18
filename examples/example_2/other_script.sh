#!/usr/bin/env bash
# shellcheck disable=SC2155,SC2016

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

__other_script_version="1.0.0"
__other_script_date="$( date +%Y-%m-%d )"
__other_script_author="Rafael Mori"
__other_script_description="This script is a template for creating secure bash scripts."
__other_script_use_type="exec" # "lib" or "exec". lib if you want to use it as a library, exec if you want to run it as a standalone script.

###################################################################################
# General Information:
# 
# All 'myname' prefixes must be replaced with your script reference. 
# For example, if your script is named 'grep_and_tail.sh',
# replace 'myname' with 'grep_and_tail' in all function names and variables.
# This ensures that the script is self-contained and does not interfere with other scripts.
# 
#################################################################################

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

###############################################################################
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
# __other_script_export_functions
#
# Wraps the main functions to be executed. It will handle the execution of what
# is passed as an argument. It also exports the appropriate functions
# to the environment, ensuring they are available if the pourpose is to be
# sourced.
#
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

###############################################################################
# __other_script_exec_function
#
# Executes a function if it exists. If the function does not exist, it logs an
# error message using kbx_log or prints an error message to stderr.
# The function name is passed as the first argument, and any additional
# arguments are passed to the function when it is executed.
#
###############################################################################
__other_script_exec_function() {
  local _func_name="${1:-}"  # Sempre captura o primeiro argumento como nome da função
  local _func_full_args=( "$@" )   # Captura o segundo argumento como os parâmetros da função
  local _func_args=( "${_func_full_args[@]:1}" ) # Remove o primeiro argumento para que $@ contenha apenas os parâmetros
  #shift                      # Remove o primeiro argumento para que $@ contenha apenas os parâmetros

  if [[ -z "$_func_name" ]]; then
    echo "Erro: Nenhuma função foi especificada para execução." 1>&2
    return 1
  fi

  # kbx_log info "Function name: ${_func_name}"
  # kbx_die 0 "Args: ${_func_args[*]}"

  if declare -F "$_func_name" >/dev/null 2>&1; then
    "$_func_name" "${_func_args[@]}"  # Executa a função com os argumentos restantes
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
### BEGINNING OF SCRIPT LOGIC IN A SAFE ENVIRONMENT

#################################################################################
# Tree internal logic
#
# The following functions are used to generate a tree view of a directory
# structure, including file types and sizes. The tree_with_types function
# recursively traverses the directory and its subdirectories, while the
# tree_with_types_html function generates an HTML representation of the tree.
# The __get_file_type function determines the MIME type of a file based on its
# content and file extension. The script also includes a function to handle
# user confirmation before proceeding with the tree view generation.
# 
#################################################################################
__get_file_type() {
  local file="${1:-}"
  local mime_type

  if [ -z "$file" ]; then
    echo "File not provided" >&2
    return 1
  fi

  if [ -d "$file" ]; then
    echo "directory"
    return 0
  fi

  # Check for specific content patterns
  if grep -qE '^\s*---\s*$' "$file" || grep -qE '^\s*[a-zA-Z0-9_-]+:\s*' "$file"; then
    mime_type="application/x-yaml"
  elif grep -qE '^\s*\{\s*"' "$file"; then
    mime_type="application/json"
  elif grep -qE '^\s*#!/bin/(bash|sh|zsh)' "$file"; then
    mime_type="text/x-shellscript"
  else
    # Use head and strings for additional checks
    local head_output=""
    head_output=$(sudo head -n 1 "$file") || return 61
    local strings_output=""
    strings_output=$(sudo strings "$file" | sudo head -n 10) || return 61

    if echo "$head_output" | grep -qE '^\s*---\s*$' || echo "$strings_output" | grep -qE '^\s*[a-zA-Z0-9_-]+:\s*'; then
      mime_type="application/x-yaml"
    elif echo "$head_output" | grep -qE '^\s*\{\s*"' || echo "$strings_output" | grep -qE '^\s*\{\s*"'; then
      mime_type="application/json"
    elif echo "$head_output" | grep -qE '^\s*#!/bin/(bash|sh|zsh)' || echo "$strings_output" | grep -qE '^\s*#!/bin/(bash|sh|zsh)'; then
      mime_type="text/x-shellscript"
    else
      # Fallback to file extension check
      case "${file##*.}" in
        yml|yaml)
          mime_type="application/x-yaml"
          ;;
        json)
          mime_type="application/json"
          ;;
        sh)
          mime_type="text/x-shellscript"
          ;;
        *)
          # Use file command as a last resort
          mime_type=$(sudo file -b --mime-type "$file") || return 61
          ;;
      esac
    fi
  fi

  echo "$mime_type" || return 61
  return 0
}


__get_file_type___() {
  local _file=$1
  sudo -u root file "${_file}" | sudo awk -F': ' '{print $2}' | sudo awk -F',' '{print $1}'
  return 0
}

_tree_lt () {
  local _original_dir=${1:-}
  local _dir=${2:-${_original_dir:-}}
  if [ -z "$_dir" ]; then
    kbx_die 1 "Directory not provided"
  fi
  if sudo test ! -d "$_dir"; then
    kbx_die 1 "Directory not found: ${_dir}"
  fi
  local _total_files=$(sudo -u root find -P "${_original_dir}/" -type f | wc -l) >/dev/null || true
  local _total_dirs=$(sudo -u root find -P "${_original_dir}/" -type d | wc -l) >/dev/null || true
  local _total_content=$(( _total_files + _total_dirs )) >/dev/null || true
  if test $_total_content -gt 500; then
    kbx_log info "There are $_total_content objects, files and directories, in the given target."
    kbx_br || true
    kbx_log info "Do you want to proceed with the tree view [y/N]?"
    local _proceed_with_tree="$(kbx_yes_no_question "" "n" 5)"
    if [[ "${_proceed_with_tree}" =~ ^[Nn] ]]; then
      kbx_die 0 "Operation canceled by user"
    fi
  fi
  kbx_clear_keeping_buffer || true
  kbx_br || true
  kbx_br || true
	sudo -u root tree -ghQuaC -pf --du --sort="name" --metafirst "${_dir}" -I "*\.git*" || kbx_die 2 "Error listing directory: ${_dir}"
  return 0
}
treeGit () {
  local _original_dir=${1:-}
  local _dir=${2:-${_original_dir:-}}
  if [ -z "$_dir" ]; then
    kbx_die 1 "Directory not provided"
  fi
  if sudo test ! -d "$_dir"; then
    kbx_die 1 "Directory not found: ${_dir}"
  fi
  local _total_files=$(sudo -u root find -P "${_original_dir}/" -type f | wc -l) >/dev/null || true
  local _total_dirs=$(sudo -u root find -P "${_original_dir}/" -type d | wc -l) >/dev/null || true
  local _total_content=$(( _total_files + _total_dirs )) >/dev/null || true
  if test $_total_content -gt 500; then
    kbx_log info "There are $_total_content objects, files and directories, in the given target."
    kbx_br || true
    kbx_log info "Do you want to proceed with the tree view [y/N]?"
    local _proceed_with_tree="$(kbx_yes_no_question "" "n" 5)"
    if [[ "${_proceed_with_tree}" =~ ^[Nn] ]]; then
      kbx_die 0 "Operation canceled by user"
      return 0
    fi
  fi
  kbx_clear_keeping_buffer || true
  kbx_br || true
  kbx_br || true
	sudo -u root tree -ghQuaC -pf --du --sort="name" --metafirst "${_dir}" || kbx_die 2 "Error listing directory: ${_dir}"
  return 0
}
tree_with_types() {
  local _original_dir=${1:-}
  local _dir=${2:-${_original_dir:-}}
  local _prefix=${3:-}
  local _output_buffer="${4:-}"

  if [ -z "$_dir" ]; then
    kbx_die 1 "Directory not provided"
  fi
  if sudo test ! -d "$_dir"; then
    kbx_die 1 "Directory not found: ${_dir}"
  fi

  if [ -z "$_prefix" ]; then
    _prefix=""
    if test "${_original_dir}" == "${_dir}"; then
      local _total_files=$(sudo -u root find -P "${_original_dir}/" -type f | wc -l) >/dev/null || true
      local _total_dirs=$(sudo -u root find -P "${_original_dir}/" -type d | wc -l) >/dev/null || true
      local _total_content=$(( _total_files + _total_dirs )) >/dev/null || true
      if test $_total_content -gt 500; then
        kbx_log info "There are $_total_content objects, files and directories, in the given target."
        kbx_br || true
        kbx_log info "Do you want to proceed with the tree view [y/N]?"
        local _proceed_with_tree="$(kbx_yes_no_question "" "n" 5)"
        if [[ "${_proceed_with_tree}" =~ ^[Nn] ]]; then
          kbx_die 0 "Operation canceled by user"
          return 0
        fi
      fi
    fi
  fi

  local _current_total_children=$(sudo -u root find -P "${_dir}/" -mindepth 1 -maxdepth 1 | wc -l)
  local _counter=0
  while IFS= read -r -d '' _file; do
    _file="${_file%$'\0'}"
    _counter=$((_counter + 1))
    local _type="$(__get_file_type "${_file}")" >/dev/null || true
    if [[ "$_type" == "directory" ]]; then
      if [[ "$_original_dir" == "$_dir" ]]; then
        if [[ $_counter -eq 1 ]]; then
          printf '%b' "\nLoading tree of: $(realpath "${_original_dir}")"$'\n\n' > /dev/tty
          printf '%b' "${_prefix} ┌───\033[34m\"${_file}\"\033[0m  Directory"$'\n' > /dev/tty
        else
          printf '%b' "${_prefix} ├───\033[34m\"${_file}\"\033[0m  Directory"$'\n' > /dev/tty
        fi
        tree_with_types "${_original_dir}" "${_file}" "${_prefix} │   "
      else
        if [[ $_counter -eq $_current_total_children ]]; then
          printf '%b' "${_prefix} └───\033[34m\"${_file}\"\033[0m  Directory"$'\n' > /dev/tty
          _output_buffer+=$(tree_with_types "${_original_dir}" "${_file}" "${_prefix}    ")
        else
          printf '%b' "${_prefix} ├───\033[34m\"${_file}\"\033[0m  Directory"$'\n' > /dev/tty
          tree_with_types "${_original_dir}" "${_file}" "${_prefix} │  "
        fi
      fi
    else
      local _info="$(sudo du -h "${_file}" | sudo awk '{print $1}' | sudo tr -d '\n')" >/dev/null || true
      if [[ $_counter -eq $_current_total_children ]]; then
        _output_buffer+="${_prefix} └───\033[32m\"${_file}\"\033[0m  ${_type} [size: ${_info}]"$'\n'
      else
        _output_buffer+="${_prefix} ├───\033[32m\"${_file}\"\033[0m  ${_type} [size: ${_info}]"$'\n'
      fi
    fi
  done < <(sudo -u root find -P "$_dir" -mindepth 1 -maxdepth 1 -type d -print0 && sudo -u root find -P "$_dir" -mindepth 1 -maxdepth 1 -not -type d -print0)

  printf '%b' "$_output_buffer" > /dev/tty

  if [[ "${_original_dir}" == "${_dir}" ]]; then
    local _total_files=$(sudo -u root find -P "${_original_dir}/" -type f | wc -l) >/dev/null || true
    local _total_dirs=$(sudo -u root find -P "${_original_dir}/" -type d | wc -l) >/dev/null || true

    test "$_total_files" -gt 0 && _total_files="files:$_total_files" || _total_files='files:0'
    test "$_total_dirs" -gt 0 && _total_dirs="dirs:$_total_dirs" || _total_dirs='dirs:0'

    printf '%b' "${_prefix} │  "$'\n' > /dev/tty
    printf '%b' "${_prefix} └───\033[34m\"${_original_dir}\"\033[0m [${_total_files} ${_total_dirs}]"$'\n\n' > /dev/tty
  fi

  return 0
}
tree_with_types_html() {
  local _original_dir=${1:-}
  local _dir=${2:-${_original_dir:-}}
  local _prefix=${3:-}
  if [ -z "$_dir" ]; then
    _dir="."
  fi
  if [ -z "$_prefix" ]; then
    _prefix=""
  fi
  
  local _current_total_children=$(sudo -u root find "${_dir}/" -mindepth 1 -maxdepth 1 | wc -l)
  local _counter=0
  while IFS= read -r -d '' _file; do
    _file="${_file%$'\0'}"
    _counter=$((_counter + 1))
    local _type="$(__get_file_type "${_file}")" >/dev/null || true
    if [[ "$_type" == "directory" ]]; then
      if [[ "$_original_dir" == "$_dir" ]]; then
        if [[ $_counter -eq 1 ]]; then
          kbx_clear_keeping_buffer || true
          echo '<html><head><meta charset="utf-8"><meta http-equiv="X-UA-Compatible" content="IE=edge">'
          echo '<meta name="viewport" content="width=device-width, initial-scale=1">'
          echo "<title>Tree of: ${_original_dir}</title>"
          echo '<style>'
          echo '    body { font-family: monospace; }'
          echo '    .boxh { display: inline-block; width: 10px; height: 10px; background-color: black; }'
          echo '    .boxv { display: inline-block; width: 10px; height: 10px; background-color: black; }'
          echo '    .boxur { display: inline-block; width: 10px; height: 10px; background-color: black; }'
          echo '    .boxvr { display: inline-block; width: 10px; height: 10px; background-color: black; }'
          echo '    .boxul { display: inline-block; width: 10px; height: 10px; background-color: black; }'
          echo '    .boxvl { display: inline-block; width: 10px; height: 10px; background-color: black; }'
          echo ' </style>'
          echo '</head><body><div> <h1>Tree of: ${_original_dir}</h1> </div><div class="container"><pre>'
          echo "${_prefix}&boxvr;&boxh;&boxh; <span style='color: blue;'>\"${_file}\"</span>  ${_type}<br>"
        else
          echo "${_prefix}&boxvr;&boxh;&boxh; <span style='color: blue;'>\"${_file}\"</span>  ${_type}<br>"
        fi
        tree_with_types_html "${_original_dir}" "${_file}" "${_prefix}&boxv;&nbsp;&nbsp;&nbsp;"
      else
        if [[ $_counter -eq $_current_total_children ]]; then
          echo "${_prefix}&boxur;&boxh;&boxh; <span style='color: blue;'>\"${_file}\"</span>  ${_type}<br>"
          tree_with_types_html "${_original_dir}" "${_file}" "${_prefix}&boxv;&nbsp;&nbsp;&nbsp;"
        else
          echo "${_prefix}&boxvr;&boxh;&boxh; <span style='color: blue;'>\"${_file}\"</span>  ${_type}<br>"
          tree_with_types_html "${_original_dir}" "${_file}" "${_prefix}&boxv;&nbsp;&nbsp;&nbsp;"
        fi
      fi
    else
      local _info="$(sudo du -h "${_file}" | sudo awk '{print $1}' | sudo tr -d '\n')" >/dev/null || true
      if [[ $_counter -eq $_current_total_children ]]; then
        echo "${_prefix}&boxur;&boxh;&boxh; <span style='color: green;'>\"${_file}\"</span>  ${_type} [size: ${_info}]<br>"
      else
        echo "${_prefix}&boxvr;&boxh;&boxh; <span style='color: green;'>\"${_file}\"</span>  ${_type} [size: ${_info}]<br>"
      fi
    fi
  done < <(find "$_dir" -mindepth 1 -maxdepth 1 -print0)

  if [[ "${_original_dir}" == "${_dir}" ]]; then
    local _total_files=$(sudo -u root find "${_original_dir}/" -type f | wc -l) >/dev/null || true
    local _total_dirs=$(sudo -u root find "${_original_dir}/" -type d | wc -l) >/dev/null || true
    test "$_total_files" -gt 0 && _total_files="files:$_total_files" || _total_files='files:0'
    test "$_total_dirs" -gt 0 && _total_dirs="dirs:$_total_dirs" || _total_dirs='dirs:0'
    echo -e "${_prefix}&boxv;&nbsp;&nbsp;&nbsp;"
    echo "${_prefix}&boxvr;&boxh;&boxh; <span style='color: blue;'>\"${_original_dir}\"</span>  [${_total_files} ${_total_dirs}]<br>"
    echo "</pre></div></body></html>"
  fi

  return 0
}

###############################################################################
# second_function
#
# This function is a wrapper for the tree_with_types function.
# It checks the first argument and calls the appropriate function based on it.
# If the first argument is "tree" and the second argument is "html",
# it calls tree_with_types_html. Otherwise, it calls tree_with_types.
# It also handles the case where no arguments are provided.
# If no arguments are provided, it defaults to calling tree_with_types.
# It returns 0 on success and 1 on failure.
#
###############################################################################
second_function() {
  local _arg1="${1:-}"
  local _arg2="${2:-}"
  local _arg3="${3:-}"
  local _full_args=( "$@" )
  local _arg_len="${#_full_args[@]}"

  if test "${_arg1}" = "tree"; then
    if test "${_arg2}" = "types"; then
      if test "${_arg3}" = "html"; then
        tree_with_types_html "${_full_args[@]:3:$_arg_len}" || return 1
      else
        tree_with_types "${_full_args[@]:2:$_arg_len}" || return 1
      fi
    else
      if test "${_arg1}" = "git"; then
        treeGit "${_full_args[@]:1:$_arg_len}" || return 1
      else 
        _tree_lt "${_full_args[@]}"
      fi
    fi
  else
    kbx_die 1 "Invalid argument: ${_arg1}"
  fi
  return 0
}

### END OF SCRIPT LOGIC, BELOW WE ENSURE ISOLATION
###############################################################################
# __other_script_main
#
# Main entry point of the script. Executes the function passed as an argument
# only after all validations and environment configurations.
################################################################################
__other_script_main() {
  # shellcheck disable=SC2155
  local _ws_name="$(__other_script_sourced_name)"
  eval "local _ws_name=\$${_ws_name}" >/dev/null

  # shellcheck disable=SC2116
  if test "$(echo "${_ws_name}")" != "true"; then # If the script is not sourced
    __other_script_exec_function "$@"
    exit $?
  else
    # __other_script_export_functions
    kbx_die 1 "This script is not intended to be sourced."
  fi
}

# All logic executed here if initial validation is successful
__other_script_main "$@"
