#!/bin/bash
# ======================================================================================================
# includes
# ======================================================================================================
. "$PROJECTDIR/env/system.sh" || exit

# ======================================================================================================
# Maintenance functions
# ======================================================================================================
. "$PROJECTDIR/functions/os.sh" || exit

# ==========================================================================
# Parameters:
# -
# Return:
#   error code or 0
# ==========================================================================
function f_maintenance_enable() {
  secret="mercy-6544435c-2e1a-1001-845f"
  f_output_info "Enabling maintenance with secret: $secret"
  php artisan down --secret='$secret'
  exit_code=$?
  if [[ exit_code -eq 0 ]]; then
    f_output_success "OK\n"
  fi
  return $exit_code
}

# ==========================================================================
# Parameters:
# -
# Return:
#   error code or 0
# ==========================================================================
function f_maintenance_disable() {
  f_output_info "Disabling maintenance ..."
  php artisan up
  exit_code=$?
  if [[ exit_code -eq 0 ]]; then
    f_output_success "OK\n"
  fi
  return $exit_code
}

# ==========================================================================
# backup files
#
# Parameters:
# -
# Return:
#   error code or 0
# ==========================================================================
function f_backup_files() {
  f_output_info "Backup magento files (app/etc/*, auth.json, composer, etc) ..."

  # get UUID and store it in var_os_last_uuid
  f_os_uuid
  today=`date +%Y%m%d`
  magento_backup_folder="$destination_mercy_root_path/__backups__/$today-$var_os_last_uuid"
  mkdir -p "$magento_backup_folder" || exit

  cp -r "$destination_mercy_root_path/app/etc" "$magento_backup_folder"
  cp -r "$destination_mercy_root_path/auth.json" "$magento_backup_folder"
  cp -r "$destination_mercy_root_path/composer.json" "$magento_backup_folder"
  cp -r "$destination_mercy_root_path/composer.lock" "$magento_backup_folder"
#  cp -r "$destination_mercy_root_path/vendor" "$magento_backup_folder"

  return 0
}


