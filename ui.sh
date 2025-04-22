#!/bin/bash
# ======================================================================================================
# Deployment any (local or prod) instance
# ======================================================================================================

# =============================================
# Checking location is the script folder
# =============================================
BASEDIR=$(readlink -f "$0")
BASEDIR=$(dirname "$BASEDIR")
#if [[ $BASEDIR != *"scripts/deployment" ]]; then
#  echo "Wrong script directory!"
#  echo $BASEDIR
#  exit
#fi

# =============================================
# generate system.sh by parsing template ...
# =============================================
if [ "$1" != "-n" ]; then
  php artisan deploy-env:update-bash || exit
fi

# =============================================
# Preparing ...
# =============================================
PROJECTDIR="$BASEDIR/bash-scripts"

# =============================================
# Read default values ...
# =============================================
. "$PROJECTDIR/env/system.default.sh"

# =============================================
# Read config ...
# =============================================
. "$PROJECTDIR/env/system.sh"

# =============================================
# include functions we need ...
# =============================================
. "$PROJECTDIR/functions/output.sh"
. "$PROJECTDIR/functions/confirmation.sh"
. "$PROJECTDIR/functions/mysql.sh"
. "$PROJECTDIR/functions/env.sh" || exit
. "$PROJECTDIR/functions/maintenance.sh"

# =============================================
# calculate variables depends on config
# =============================================
fullModulePath="$destination_mercy_root_path/$mercyModuleDirectory"

# =============================================
# Check settings ...
# =============================================

#f_output_info "Checking system basic settings ..."
f_env_check_system_basics
if [ $? -eq 0 ]; then
  f_output_success "Basic settings ok."
else
  exit
fi

#f_output_info "Checking location settings ..."
f_env_check_mercy_location
if [ $? -eq 0 ]; then
  f_output_success "Location ok."
else
  exit
fi

#f_output_info "Checking DB settings ..."
f_env_check_db_settings
if [ $? -eq 0 ]; then
  f_output_success "DB settings ok."
else
  exit
fi

f_env_check_mercy_deploy_mode_developer
mercy_deploy_mode_developer=$?
if [ $mercy_deploy_mode_developer -eq 0 ]; then
  mercy_deploy_mode="DEVELOPER (local,dev,dusk-testing)"
  deploy_env_option="--dev-mode"
else
  mercy_deploy_mode="PRODUCTION (composer --no-dev)"
  deploy_env_option=""
fi

# =============================================
# Ask
# =============================================

# ask to run
#f_confirmation_mercy_root_settings "Start UI for $mercy_deploy_mode ..."
#[ ! $? -eq 0 ] && { exit 1; } # return not 0 = error and exit

# =============================================
# UI
# =============================================

function f_show_ui() {
  f_output_info "Press any key to show menu (clear screen) ..."
  read -s -N 1 SELECT
  clear
  f_output_system_info "Mercy Menu"
  f_output_info "[c] Clear Cache"
  f_output_info "[b] Build Frontend (incl. Caches)"
  f_output_info "[u] System Update (deployment/run.sh)"
  f_output_info "    - git update app"
  f_output_info "    - git update modules SystemBase, DeployEnv"
  f_output_info "    - require-dependencies : Updating Modules, Themes, Composer, Frontend, Caches"
  f_output_info "[e] (extern) System Update (deployment/run-extern.sh)"
  f_output_info "    - git update app"
  f_output_info "    - git update all modules in /Modules"
  f_output_info "    - composer dump-autoload"
  f_output_info "    - composer update"
  f_output_info "[r] (raw) (like extern but w/o artisan) System Update"
  f_output_info "    - git update app"
  f_output_info "    - git update all modules and themes"
  f_output_info "    - composer dump-autoload"
  f_output_info "    - composer update"
  f_output_info "[p] Git pull main app only"
  f_output_info "[o] Optimize (Cache config, routes, events, ...)"
  f_output_info "[i] ide-helper generate (facades,models,meta)"
  f_output_info "[t] show last log (using less, press 'ctrl+c', 'q' to exit)"
  f_output_info "[q] Quit"
  f_output_line_separator
  #  f_confirmation_ask_key "Press key: "
  #  return $?
}

#
cd "$destination_mercy_root_path" || exit

SELECT=""
# prevent parsing of the input line
IFS=''

#while [[ "$SELECT" != $'\x0a' && "$SELECT" != $'\x20' ]]; do
#  echo "Select session type:"
#  echo "Press <Enter> to do foo"
#  echo "Press <Space> to do bar"
#  read -s -N 1 SELECT
#  echo "Debug/$SELECT/${#SELECT}"
#  [[ "$SELECT" == $'\x0a' ]] && echo "enter" # do foo
#  [[ "$SELECT" == $'\x20' ]] && echo "space" # do bar
#done

while [ true ]; do

  f_show_ui
  read -s -N 1 SELECT

  if [[ "$SELECT" == $'q' ]]; then
    f_output_info "Quit ..."
    exit 1
  fi

  if [[ "$SELECT" == $'c' ]]; then
    f_output_info "Clearing Caches ..."
    php artisan deploy-env:cc || exit
  fi

  if [[ "$SELECT" == $'b' ]]; then
    f_output_info "Lets Build Frontend ..."
    php artisan deploy-env:build-frontend || exit
  fi

  if [[ "$SELECT" == $'p' ]]; then
    f_output_info "Starting Git Pull ..."
    git pull || exit
  fi

  if [[ "$SELECT" == $'o' ]]; then
    f_output_info "Optimizing ..."
    php artisan optimize || exit
  fi

  if [[ "$SELECT" == $'u' ]]; then
    f_output_info "Starting deployment run ..."
    cd bash-scripts/scripts/deployment || exit
    ./run.sh || exit
    cd "$destination_mercy_root_path" || exit
  fi

  if [[ "$SELECT" == $'e' ]]; then
    f_output_info "Starting extern deployment ..."
    cd bash-scripts/scripts/deployment || exit
    ./run-extern.sh || exit
    cd "$destination_mercy_root_path" || exit
  fi

  if [[ "$SELECT" == $'r' ]]; then
    f_output_info "Starting raw/extern deployment ..."
    cd bash-scripts/scripts/deployment || exit
    ./raw-update.sh || exit
    cd "$destination_mercy_root_path" || exit
  fi

  if [[ "$SELECT" == $'i' ]]; then
    f_output_info "Starting ide-helper ..."
    php artisan clear-compiled || exit
    php artisan ide-helper:generate || exit
    php artisan ide-helper:models -M || exit
    php artisan ide-helper:meta || exit
  fi

  if [[ "$SELECT" == $'t' ]]; then
    f_output_info "Starting tail ..."
    logsDir="storage/logs"
    tmp=$(ls "$logsDir" -t1 | head -n 1)
    echo "Showing $tmp:"
    less +F "$logsDir/$tmp"
  fi


done
