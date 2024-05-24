#!/bin/bash
# ======================================================================================================
# Test some ...
#
# ======================================================================================================

# =============================================
# Preparing ...
# =============================================
PROJECTDIR="../.."

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


# =============================================
# Print confirmations but do nothing ...
# =============================================
f_confirmation_db_settings "Testing confirmation 1 and doing nothing ..."
f_confirmation_mercy_root_settings "Testing confirmation 2 and doing nothing ..."
