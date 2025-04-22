#!/bin/bash
# ======================================================================================================
# All commands without artisan, just plain system calls.
# 1) git fetch and checkout all modules and themes already installed
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
PROJECTDIR="$BASEDIR/../.."

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
  deploy_env_option="--dev-mode --debug"
else
  deploy_env_option=""
fi

branchToCheckout="$defaultBranch"
# Argument validation check
if [ "$#" -eq 1 ]; then
  branchToCheckout="$1"
fi

# =============================================
# Do the task
# =============================================

# change to mercy root
cd "$destination_mercy_root_path" || exit

f_output_info "Starting git checkouts for branch '$branchToCheckout'..."
cd bash-scripts/scripts/git || exit
eval "./checkout-one-branch-for-all-modules.sh $branchToCheckout" || exit

# change back to mercy root
cd "$destination_mercy_root_path" || exit

#f_output_info "Starting composer"
composer dump-autoload
composer update

# restore current directory
cd "$BASEDIR" || exit
