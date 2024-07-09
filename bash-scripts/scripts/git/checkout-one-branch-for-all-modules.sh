#!/bin/bash
#su - hiroki

# =============================================
# Checking location is the script folder
# =============================================
BASEDIR=$(readlink -f "$0")
BASEDIR=$(dirname "$BASEDIR")
if [[ $BASEDIR != *"git" ]]; then
  echo "Wrong script directory!"
  echo $BASEDIR
  exit
fi

# =============================================
# Preparing ...
# =============================================
PROJECTDIR="../.."
branchToCheckout="master"

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

# =============================================
# calculate variables depends on config
# =============================================
fullModulePath="$destination_mercy_root_path/$mercyModuleDirectory"

# =============================================
# Confirmation
# =============================================
f_confirmation_mercy_root_settings "Checkout branch '$branchToCheckout' for all GIT repositories\nin '$fullModulePath'?"
[ ! $? -eq 0 ] && { exit 1; } # return not 0 = error and exit

# =============================================
#
# =============================================
for d in $fullModulePath/*; do
  if [ -d "$d" ]; then
    # check its a git repo
    if [ -f "$d/.git/config" ]; then
      echo "$d : git fetch and checkout ..."
      cd "$d" || exit
#      git fetch origin "$branchToCheckout"
#      git checkout "$branchToCheckout"
      echo "" # new line
    fi
  fi
done

cd "$BASEDIR" || exit


