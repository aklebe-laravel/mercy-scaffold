#!/bin/bash
# ======================================================================================================
# Operation system specific functions
# ======================================================================================================
var_os_last_uuid=""

# ==========================================================================
# Parameters:
# Return:
#   ...
# ==========================================================================
function f_os_uuid() {

  uuid=$(uuidgen)
  uuid=${uuid^^}
  var_os_last_uuid="$uuid"
  return 0

}

# =============================================
# Parameters:
# 1) directory
# 2) branch
# Return:
#   ...
# =============================================
function gitFetchAndCheckout() {

  # check its a git repo
  if [ -f "$1/.git/config" ]; then

    cd "$1" || exit
    echo "Try checkout branch '$2' in '$1' ..."

#    if output=$(git status --porcelain) && [ -z "$output" ]; then
    if [ -z "$(git status --untracked-files=no --porcelain)" ]; then
      git fetch origin "$2" || return 101
      git checkout "$2" || return 102
      git pull || return 103
      echo "OK!"
      echo "" # new line
    else
      echo "Skipped! No clean git repository."
      echo "" # new line
      # no error
    fi

  else

    echo "No git found in '$1'."
    return 110

  fi

  return 0
}


