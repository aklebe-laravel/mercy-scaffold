#!/bin/bash
# =============================================
# Env system:
# something like: local,dev,int,prod,dev-channel,local-ak,prod-fake,prod-2.3.5,etc...
# used for folders and/or branches
# =============================================
destination_env_system="dev"

# =============================================
# Env Box:
#   default: server like production hostings
#   possible values: "default", "zepgram", ...
# =============================================
destination_env_box=""

# =============================================
# Source settings
# Used for exported dumps (the search values for "search and replace")
# =============================================
source_host="localhost"
source_db_user="user1"

# =============================================
# Destination settings
# =============================================
destination_db_host="localhost"
destination_db_port="3306"
destination_db_name="db_my_project"
destination_db_user="homestead"
destination_db_password="secret"
destination_mercy_root_path="/home/vagrant/projects/MyProject"

# =============================================
# Composer
# values like "composer" or "./composer.phar"
# =============================================
composer_executable="composer"

# =============================================
# Miscellaneous
# =============================================
mercyModuleDirectory="Modules"
dark_theme=1 # 0 or 1
delete_dump=1
