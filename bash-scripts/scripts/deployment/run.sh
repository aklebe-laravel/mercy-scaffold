#!/bin/bash
# ======================================================================================================
# Deployment any (local or prod) instance
# ======================================================================================================

# =============================================
# Checking location is the script folder
# =============================================
BASEDIR=$(readlink -f "$0")
BASEDIR=$(dirname "$BASEDIR")
if [[ $BASEDIR != *"scripts/deployment" ]]; then
  echo "Wrong script directory!"
  echo $BASEDIR
  exit
fi

# =============================================
# Preparing ...
# =============================================
PROJECTDIR="../.."

# =============================================
# Read default values ...
# =============================================
. "$PROJECTDIR/env/system.default.sh"

# =============================================
# Read config ...
# =============================================
. "$PROJECTDIR/env/system.sh" || exit

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

f_env_check_mercy_deploy_mode_developer
mercy_deploy_mode_developer=$?
if [ $mercy_deploy_mode_developer -eq 0 ]; then
  deploy_env_option="--dev-mode"
else
  deploy_env_option=""
fi

# =============================================
# Do the task
# =============================================

# ask to run
f_confirmation_mercy_root_settings "Run Deployment ..."
[ ! $? -eq 0 ] && { exit 1; } # return not 0 = error and exit

# change to mercy root
cd "$destination_mercy_root_path" || exit

# enable maintenance
f_maintenance_enable || exit

# app pull
f_output_info "Git Update App"
git pull || exit
echo "" # new line

# @todo: check also if this script was updated and restart it
# ...

# pull module
currentModule="SystemBase"
f_output_info "Git Update Module $currentModule"
cd "$fullModulePath/$currentModule" || exit
git pull || exit
echo "" # new line

# pull module
currentModule="DeployEnv"
f_output_info "Git Update Module $currentModule"
cd "$fullModulePath/$currentModule" || exit
git pull || exit
echo "" # new line

# change back to mercy root
cd "$destination_mercy_root_path" || exit

# deploy all-in-one dependencies
if [[ -z "$deploy_env_option" ]]; then
  php artisan deploy-env:require-dependencies || exit
else
  php artisan deploy-env:require-dependencies "$deploy_env_option" || exit
fi

# enable maintenance
f_maintenance_disable || exit

# finish
f_output_success "Deployment finished successfully!\n"

# restore current directory
cd "$BASEDIR" || exit
