#!/bin/bash
# ======================================================================================================
# Test some ...
#
# ======================================================================================================

# =============================================
# Preparing ...
# =============================================
PROJECTDIR="$BASEDIR/../.."

# =============================================
# Read default values ...
# =============================================
. "$PROJECTDIR/env/system.default.sh"

# =============================================
# Read user config ...
# =============================================
env_system_file="$PROJECTDIR/env/system.sh"
. $env_system_file

# =============================================
# include functions we need ...
# =============================================
. "$PROJECTDIR/functions/output.sh"
. "$PROJECTDIR/functions/confirmation.sh"
. "$PROJECTDIR/functions/mysql.sh"
. "$PROJECTDIR/functions/env.sh" || exit
. "$PROJECTDIR/functions/maintenance.sh"


## =============================================
## Switch to Magento root path before checking every stuff?
## =============================================
#cd "$destination_mercy_root_path" || {
#  f_output_error "Fehler beim Verzeichniswechsel."
#  exit
#}

# =============================================
# Checking things ...
# =============================================
f_output_info ""

#f_output_info "Checking system basic settings ..."
f_env_check_system_basics
if [ $? -eq 0 ]; then
  f_output_success "Basic settings ok."
else
  exit
fi

#f_output_info "Checking location setting ..."
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

magento_deploy_mode_developer=$?
if [ $magento_deploy_mode_developer -eq 0 ]; then
  f_output_info "Magento deploy mode: DEVELOPER"
else
  f_output_warning "Magento deploy mode: PRODUCTION"
fi

f_output_info ""
