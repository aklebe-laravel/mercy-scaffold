#!/bin/bash
# ======================================================================================================
# Cleanup all magento caches, redis cache, remove cache folders
# ======================================================================================================

# =============================================
# Checking location is the script folder
# =============================================
BASEDIR=$(readlink -f "$0")
BASEDIR=$(dirname "$BASEDIR")
if [[ $BASEDIR != *"scripts/cleanup" ]]; then
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
. "$PROJECTDIR/env/git-staging-data.sh"

# =============================================
# include functions we need ...
# =============================================
. "$PROJECTDIR/functions/output.sh"
. "$PROJECTDIR/functions/confirmation.sh"
. "$PROJECTDIR/functions/maintenance.sh"

# =============================================
# calculate variables depends on config
# =============================================
# ...

# =============================================
# Confirmation
# =============================================
f_confirmation_mercy_root_settings "Cleanup all caches ..."
[ ! $? -eq 0 ] && { exit 1; } # return not 0 = error and exit

# =============================================
# Do the task
# =============================================
# magento cache cleanup
php artisan deploy-env:cc || exit

# restore current directory
cd "$BASEDIR" || exit
