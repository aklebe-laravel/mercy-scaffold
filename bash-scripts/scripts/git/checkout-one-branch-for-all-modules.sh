#!/bin/bash
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

# Argument validation check
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <branchToCheckout>"
    exit 1
fi

# =============================================
# Preparing ...
# =============================================
PROJECTDIR="$BASEDIR/../.."
branchToCheckout="$1"

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
. "$PROJECTDIR/functions/os.sh"
. "$PROJECTDIR/functions/confirmation.sh"

# =============================================
# calculate variables depends on config
# =============================================
if [[ -z "$mercyModuleDirectory" ]]; then
  f_output_error "No module directory defined: '$mercyModuleDirectory'"
  exit 1
fi
if [[ -z "$mercyThemeDirectory" ]]; then
  f_output_error "No theme directory defined: '$mercyThemeDirectory'"
  exit 1
fi

fullModulePath="$destination_mercy_root_path/$mercyModuleDirectory"
fullThemePath="$destination_mercy_root_path/$mercyThemeDirectory"

# =============================================
# Confirmation
# =============================================
f_confirmation_mercy_root_settings "Checkout branch '$branchToCheckout' for all GIT repositories\nin '$fullModulePath' and '$fullThemePath'?"
[ ! $? -eq 0 ] && { exit 1; } # return not 0 = error and exit

# =============================================
# App itself
# =============================================
if [ -d "$destination_mercy_root_path" ]; then
  gitFetchAndCheckout "$destination_mercy_root_path" "$branchToCheckout"
  [ ! $? -eq 0 ] && { exit 1; } # return not 0 = error and exit
fi

# =============================================
# Modules
# =============================================
for d in $fullModulePath/*; do
  if [ -d "$d" ]; then
    gitFetchAndCheckout "$d" "$branchToCheckout"
    [ ! $? -eq 0 ] && { exit 1; } # return not 0 = error and exit
  fi
done

# =============================================
# Themes
# =============================================
for d in $fullThemePath/*; do
  if [ -d "$d" ]; then
    gitFetchAndCheckout "$d" "$branchToCheckout"
    [ ! $? -eq 0 ] && { exit 1; } # return not 0 = error and exit
  fi
done

cd "$BASEDIR" || exit


