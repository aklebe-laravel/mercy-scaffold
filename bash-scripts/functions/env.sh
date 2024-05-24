#!/bin/bash
# ======================================================================================================
# Environment specific functions
# ======================================================================================================

MS_ENV_OPTION_Y=0

# ==========================================================================
# Parameters:
# Return:
#   ...
# ==========================================================================
function f_env_check_system_basics() {

  if [[ -z "$destination_env_system" ]]; then
    f_output_error "\r'destination_env_system' is not defined.\r\n"
    return 101
  fi

  return 0

}

# ==========================================================================
# Parameters:
# Return:
#   ...
# ==========================================================================
function f_env_check_mercy_location() {

  if [[ -z "$destination_mercy_root_path" ]]; then
    f_output_error "\rFile '$env_system_file' does not exists or config 'destination_mercy_root_path' is missing.\r\n"
    return 101
  fi

  if [[ ! -d "$destination_mercy_root_path" ]]; then
    f_output_error "\rDirectory does not exists: '$destination_mercy_root_path'\r\n"
    return 102
  fi

  fileToCheck="$destination_mercy_root_path/.env"
  if [[ ! -f "$fileToCheck" ]]; then
    f_output_error "\File not found: $fileToCheck\r\n"
    return 103
  fi

  fileToCheck="$destination_mercy_root_path/config/app.php"
  if [[ ! -f "$fileToCheck" ]]; then
    f_output_error "\File not found: $fileToCheck\r\n"
    return 104
  fi

  fileToCheck="$destination_mercy_root_path/public/index.php"
  if [[ ! -f "$fileToCheck" ]]; then
    f_output_error "\File not found: $fileToCheck\r\n"
    return 104
  fi

  return 0

}

# ==========================================================================
# Parameters:
# Return:
#   ...
# ==========================================================================
function f_env_check_db_settings() {

  if [[ -z "$destination_db_name" ]]; then
    f_output_error "File '$env_system_file' does not exists or config 'destination_db_name' is missing."
    return 101
  fi

  f_mysql_has_database
  res=$?
  if [[ $res != 0 ]]; then
    f_output_error "Database not found: $destination_db_name"
    return $res
  fi

  return 0
}

# ==========================================================================
# Parameters:
# Return:
#   ...
# ==========================================================================
function f_env_check_mercy_deploy_mode_developer() {

  if OUTPUT=$(cat "$destination_mercy_root_path/.env" | grep -P -o "APP_ENV\s*=\s*(local|dev)"); then
    return 0
  fi

  return 1
}

# ==========================================================================
# Parameters:
# Return:
#   ...
# ==========================================================================
function f_env_check_mercy_deploy_mode_production() {

  if OUTPUT=$(cat "$destination_mercy_root_path/app/etc/env.php" | grep -P -o "'MAGE_MODE'\s*=>\s*'production'"); then
    #  echo $OUTPUT
    return 0
  fi

  return 1
}

# ==========================================================================
# ==========================================================================
# A POSIX variable

#OPTIND=1 # Reset in case getopts has been used previously in the shell.
#while getopts ":huny:" option; do
#  case "$option" in
#  h|\?) # option h
#    echo "no help available"
#    ;;
#  y) # option y
#    MS_ENV_OPTION_Y=$OPTARG
#    #MS_ENV_OPTION_Y=1
#    ;;
#  n) # Enter a name
#    echo "option n!!!"
#    ;;
#  esac
#done
