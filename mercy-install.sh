#!/bin/bash
# ======================================================================================================
# Install mercy base files
# ======================================================================================================

if test -f ".env"; then
  if grep -Poq '^APP_KEY=.{3}' .env; then
    echo "APP_KEY already set"
    exit 1
  fi
fi

d="Modules/SystemBase"
[ -d "${d}" ] && {
  echo "Directory already exists: $d"
  exit 1
}

d="Modules/DeployEnv"
[ -d "${d}" ] && {
  echo "Directory already exists: $d"
  exit 1
}

echo "Starting installation process ..."

echo "";
echo "======================================";
echo "Clone Git Module SystemBase";
echo "======================================";
git clone https://github.com/AKlebeLaravel/system-base-module.git ./Modules/SystemBase

echo "";
echo "======================================";
echo "Clone Git Module DeployEnv";
echo "======================================";
git clone https://github.com/AKlebeLaravel/deploy-env-module.git ./Modules/DeployEnv

echo "";
echo "======================================";
echo "Clone Git Theme Bootstrap 5";
echo "======================================";
git clone https://github.com/AKlebeLaravel/bs5-theme.git ./Themes/aklebe_bs5

echo "";
echo "======================================";
echo "Copy files";
echo "======================================";
rsync -a -v --ignore-existing resources/mercy-root/ .

echo "";
echo "======================================";
echo "Starting composer update";
echo "======================================";
composer update

echo "";
echo "======================================";
echo "Starting npm update";
echo "======================================";
npm update

echo "";
echo "======================================";
echo "Generating APP KEY";
echo "======================================";
php artisan key:generate

echo "";
echo "======================================";
echo "Creating symbolic link";
echo "======================================";
php artisan storage:link

echo "";
echo "";
echo "Installation process was successfully completed.";
echo "1) Adjust your .env file";
echo "2) Run './ui.sh'";
echo "3) Select [u] for system update";
echo "";
