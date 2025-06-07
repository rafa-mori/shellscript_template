#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../template_modular.sh"

myname_azure_auth() {
  local user=$1
  local tenant=$2
  myname_log_info "Autenticando na Azure como $user (tenant: $tenant)..."
  sleep 1
  myname_log_info "Autenticação simulada OK."
}

myname_update_runner()    { myname_log_info "Atualizando runner (pod) $1 no cluster..."; sleep 1; }
myname_install_runner()   { myname_log_info "Instalando runner (pod) $1 no cluster..."; sleep 1; }
myname_uninstall_runner() { myname_log_info "Removendo runner (pod) $1 do cluster..."; sleep 1; }

myname_process_runner() {
  local runner_id=$1
  local operation=$2
  local log_file="logs/${runner_id}_${operation}.log"
  mkdir -p logs
  myname_log_info "Iniciando operação $operation para runner $runner_id" | tee "$log_file"
  "myname_${operation}_runner" "$runner_id" 2>&1 | tee -a "$log_file"
}

export -f myname_process_runner
export -f myname_update_runner
export -f myname_install_runner
export -f myname_uninstall_runner
