#!/bin/bash
# ======================================================================================================
# mysql specific functions
# ======================================================================================================

# ==========================================================================
# Parameters:
#   -
# Return:
#   error code or 0
# ==========================================================================
function f_mysql_has_database() {
#  echo -ne "Checking database '$destination_db_name' exists ... "
  mysqlshow --host=$destination_db_host --port=$destination_db_port --user=$destination_db_user --password=$destination_db_password | grep -i -E -w "$destination_db_name" 1> /dev/null
#  echo -e "ready.\r"
  return $?
}
