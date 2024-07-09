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

# =============================================
# Do the task
# =============================================

## ask to run
#f_confirmation_mercy_root_settings "Run extern Deployment ..."
#[ ! $? -eq 0 ] && { exit 1; } # return not 0 = error and exit

# change to mercy root
cd "$destination_mercy_root_path" || exit

# enable maintenance
#f_maintenance_enable || exit

# app pull
f_output_info "Pull App"
git pull || exit

# @todo: check also if this script was updated and restart it
# ...

# pull module
for d in $fullModulePath/*; do
  if [ -d "$d" ]; then
    # ${foo  <-- from variable foo
    #   ##   <-- greedy front trim
    #   *    <-- matches anything
    #   /    <-- until the last '/'
    #  }
    f_output_info "Pull Module: ${d##*/}"
    php artisan deploy-env:require-module "${d##*/}" || exit
  fi
done

# change back to mercy root
cd "$destination_mercy_root_path" || exit

f_output_info "Starting composer"
composer dump-autoload
composer update


# enable maintenance
#f_maintenance_disable || exit

# finish
f_output_success "Extern Deployment finished successfully!\n"

# restore current directory
cd "$BASEDIR" || exit
