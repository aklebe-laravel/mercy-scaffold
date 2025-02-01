#!/bin/bash

. "$PROJECTDIR/functions/env.sh" || exit

# ======================================================================================================
# output functions
#
# Colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
# ======================================================================================================

OUTPUT_COLOR_RED="\033[${dark_theme};31m"
OUTPUT_COLOR_GREEN="\033[${dark_theme};32m"
OUTPUT_COLOR_YELLOW="\033[${dark_theme};33m"
OUTPUT_COLOR_BLUE="\033[${dark_theme};34m"
OUTPUT_COLOR_PURPLE="\033[${dark_theme};35m"
OUTPUT_COLOR_NONE="\033[0m" # No Color

function f_output() {
  echo -e "${1}" >&2;
}

function f_output_default() {
  echo -e "${OUTPUT_COLOR_NONE}${1}${OUTPUT_COLOR_NONE}" >&2;
}

function f_output_error() {
  echo -e "${OUTPUT_COLOR_RED}${1}${OUTPUT_COLOR_NONE}" >&2;
}

function f_output_success() {
  echo -e "${OUTPUT_COLOR_GREEN}${1}${OUTPUT_COLOR_NONE}" >&1;
}

function f_output_warning() {
  echo -e "${OUTPUT_COLOR_YELLOW}${1}${OUTPUT_COLOR_NONE}" >&1;
}

function f_output_info() {
  echo -e "${OUTPUT_COLOR_BLUE}${1}${OUTPUT_COLOR_NONE}" >&1;
}

function f_output_decent() {
  echo -e "${OUTPUT_COLOR_PURPLE}${1}${OUTPUT_COLOR_NONE}" >&1;
}

function f_output_line_separator() {
  echo -e "--------------------------------------------------------------\r"
}

function f_output_line_separator_big() {
  echo -e "==============================================================\r"
}

function f_output_system_info() {

  f_env_check_mercy_deploy_mode_developer
  mercy_deploy_mode_developer=$?
  if [ $mercy_deploy_mode_developer -eq 0 ]; then
    mercy_deploy_mode="DEVELOPER (local,dev,dusk-testing)"
  else
    mercy_deploy_mode="PRODUCTION (composer --no-dev)"
  fi

  f_output_line_separator_big
  echo -e "$1\r"
  f_output_line_separator_big
  f_output_decent "Generated data from '.env' to 'env/system.sh':"
  f_output_info "App Name:\t\t\t$destination_app_name"
  f_output_info "App Root:\t\t\t$destination_mercy_root_path"
  f_output_info "Env Config:\t\t\t$destination_env_system > $mercy_deploy_mode"
  f_output_info "Default branch:\t\t\t$defaultBranch"
  f_output_info "Destination Database Name:\t$destination_db_name"
  f_output_info "Destination Database User:\t$destination_db_user"
  f_output_info "Composer usage:\t\t\t$composer_executable"
  f_output_line_separator

}