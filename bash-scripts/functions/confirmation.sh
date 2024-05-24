#!/bin/bash
# ==========================================================================
# Confirmation process checking 'Y'
#
# Parameters:
#   none
# Return:
#   0: OK, 1: Abort
# ==========================================================================
function f_confirmation_ask_yes_no() {

  read -p "$1 Continue? (y/n)? " -n 1 -r
  echo -e "\r\n"

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  fi

  return 1

}

# ==========================================================================
# Confirmation process checking '0-9'
#
# Parameters:
#   none
# Return:
#   selected number 0-9
#   100: Abort
# ==========================================================================
function f_confirmation_ask_number() {

  read -p "Choose a number: " -n 1 -r
  echo -e "\r\n"

  if [[ $REPLY =~ ^[0-9]+$ ]]; then
    return $REPLY
  fi

  return 100

}

## ==========================================================================
## Confirmation process asking key 'a-z' or '0-9'
##
## Parameters:
##   none
## Return:
##   selected key a-z or 0-9
##   1: Abort
## ==========================================================================
#function f_confirmation_ask_key() {
#
#  read -p "Choose a key: " -n 1 -r
#  echo -e "\r\n"
#
#  if [[ $REPLY =~ ^[a-z0-9]+$ ]]; then
#    return $REPLY
#  fi
#
#  return 1
#
#}

# ==========================================================================
# Confirm DB settings
#
# Parameters:
#   none
# Return:
#   0: OK, 1: Abort
# ==========================================================================
function f_confirmation_db_settings() {

  f_output_system_info "$1"

  f_confirmation_ask_yes_no ""
  return $?

}

# ==========================================================================
# Confirm magento root settings
#
# Parameters:
#   none
# Return:
#   0: OK, 1: Abort
# ==========================================================================
function f_confirmation_mercy_root_settings() {

  f_output_system_info "$1"

  f_confirmation_ask_yes_no ""
  return $?

}
