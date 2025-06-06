#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../template_modular.sh"

myname_process_runner() {
  local runner_id=$1
  local operation=$2
  local log_file="logs/${runner_id}_${operation}.log"
  mkdir -p logs
  myname_log_info "Iniciando operação $operation para runner $runner_id" | tee "$log_file"
  "myname_${operation}_runner" "$runner_id" 2>&1 | tee -a "$log_file"
}

myname_update_runner()    { myname_log_info "Atualizando runner $1"; sleep 1; }
myname_install_runner()   { myname_log_info "Instalando runner $1"; sleep 1; }
myname_uninstall_runner() { myname_log_info "Desinstalando runner $1"; sleep 1; }

export -f myname_process_runner
export -f myname_update_runner
export -f myname_install_runner
