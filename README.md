## Mercy Scaffold

**Mercy Scaffold** is a lightweight laravel scaffold / boilerplate to start your web projects based on modules and themes.

### Technical Features

- Up to date in base dependencies: Laravel 11, PHP 8.2, Bootstrap 5, npm 10.7
- [Module ACL](https://github.com/aklebe-laravel/acl-module) ACL Permissions and User groups stored in DB
- [Module DataTable](https://github.com/aklebe-laravel/data-table-module) Self-made datatables using Livewire, Alpine.js, Bootstrap 5
- [Module Form](https://github.com/aklebe-laravel/form-module) Use easy configured forms
- [Module DeployEnv](https://github.com/aklebe-laravel/deploy-env-module) Automatic Deployment/Terraforming with configured data like seeding
- Merging multiple composer.json files on different locations like /Modules/* and /Themes/*

Modules based on [nwidart/laravel-modules](https://github.com/nWidart/laravel-modules),
Livewire based on [mhmiton/laravel-modules-livewire](https://github.com/mhmiton/laravel-modules-livewire),
Themes based on [shipu/themevel](https://github.com/Shipu/themevel)

### Installation

By default, 6 modules should be installed to become a decent toolkit for a website:
SystemBase, DeployEnv, Acl, Form, DataTable, WebsiteBase.
The modules SystemBase and DeployEnv are required for every project.

Follow this steps to install Mercy Scaffold:

1) Change into your new application directory and checkout the mercy app scaffold:
   ```
   git clone https://github.com/aklebe-laravel/mercy-scaffold.git .
   ```

2) Start Install:
   ```
   ./mercy-install.sh
   ```
   Installation process can take several minutes and is working only once.
   The installation script will check ```APP_KEY``` in your ```.env```
   and some specific files to decide whether the installation will start or not.

3) Adjust your ```.env``` config file. At least notice the following:
   ```
   APP_URL=xxx
   DB_DATABASE=xxx
   DB_USERNAME=xxx
   DB_PASSWORD=xxx
   MODULE_DEPLOYENV_MAKE_MODULE_AUTHOR_NAME="John Doe"
   MODULE_DEPLOYENV_MAKE_MODULE_AUTHOR_EMAIL="john.doe@localhost.test"
   MODULE_DEPLOYENV_MAKE_MODULE_COMPOSER_VENDOR_NAME="john-doe-laravel"
   MODULE_DEPLOYENV_REQUIRE_MODULES_GIT="https://github.com/${{module_vendor_name}}/${{module_snake_name_git}}.git"
   MODULE_DEPLOYENV_REQUIRE_MODULES_DEFAULT_VENDOR="aklebe-laravel"
   ```

4) The following menu provides shorthand update (via git) of your installed and/or configured modules and themes based
   on the config ```config/mercy-dependencies.php```. While run this (implicit with --no-interaction), you do not
   need to care about ```composer update```, ```php artisan migrate```
   and ```php artisan deploy-env:terraform-modules```. So execute the following script and choose ```[u]``` for system
   update:
   ```
   ./ui.sh
   ```
   
   Troubleshooting:
   ```./ui.sh``` runs ```php artisan deploy-env:update-bash``` at very first to update ```system.sh``` 
   based on ```.env```. If you have errors from artisan but ```system.sh``` was properly generated before,
   you can run ```./ui.sh -n``` to avoid the update-bash. But don't do it by default.
   
   

### Update/Build

#### (Pre-)Update (externals)

If you have trouble with autoloader by installed/created new modules, it's recommended
to run type ```./ui.sh``` and press choose ```[e]``` in menu to update/find all existing modules
and calling composer dump-autoload. After that, the update/build below should work fine.

#### Update

To run all-in-one update type ```./ui.sh``` and press choose ```[u]``` in menu.

What it does for you:

1) update/require all modules
2) update/require all themes
3) do system update wich runs composer update
4) cache clearing, rebuild frontend etc.

#### Build

To build frontend via vite, refresh caches etc., type ```./ui.sh``` and press choose ```[b]``` in menu.

### Create Forms and/or DataTables

If you have modules ```Form``` and ```DataTable``` installed, you can easy create the needed files by the following
command:

```
php artisan deploy-env:former MyModule --classes=country,some-thing,AnyThing,nothing
```

This will create the datatable class, the form files and the eloquent model.
If one the files already exists, they will not be changed.
The result should look like this:

```
Modules/MyModule/app/Models/Country.php
Modules/MyModule/app/Forms/Country.php
Modules/MyModule/app/Http/Livewire/Form/Country.php
Modules/MyModule/app/Http/Livewire/DataTable/Country.php
Modules/MyModule/app/Models/SomeThing.php
Modules/MyModule/app/Forms/SomeThing.php
Modules/MyModule/app/Http/Livewire/Form/SomeThing.php
Modules/MyModule/app/Http/Livewire/DataTable/SomeThing.php
Modules/MyModule/app/Models/AnyThing.php
Modules/MyModule/app/Forms/AnyThing.php
Modules/MyModule/app/Http/Livewire/Form/AnyThing.php
Modules/MyModule/app/Http/Livewire/DataTable/AnyThing.php
Modules/MyModule/app/Models/Nothing.php
Modules/MyModule/app/Forms/Nothing.php
Modules/MyModule/app/Http/Livewire/Form/Nothing.php
Modules/MyModule/app/Http/Livewire/DataTable/Nothing.php
```

If you run it without ```--classes```, then for every eloquent model found, datatables and form will be created.

```
php artisan deploy-env:former MyModule
```

Note: more files could be created by 3rd party modules using the event ```DeployEnvFormer```.

### Files

Try to keep all stuff in modules and/or themes,
and keep the app files clean.

#### Modules

Folder ```/Modules``` for modules with their own git repo
Enable/disable your installed modules in ```modules_statuses.json```
```php artisan deploy-env:require-dependencies``` will handle it
automatically.

#### Themes

Folder ```/Themes``` for themes with their own git repo

### Testing

Ensure you have adjusted your ```.env.testing```. Especially the database part.

#### Testing all

```
php artisan test
```

#### Test all in parallel mode

```
php artisan test --parallel --processes=4
```

#### Test a specific file

Note: ```p``` is an alias for ```vendor/bin/phpunit "$@"``` with parameter -f : ```vendor/bin/pest "$@"```

```
p ./tests/Feature/CoreConfig.php
```

#### Test a class

Note: ```pf``` is an alias for ```vendor/bin/phpunit --filter "$@"``` with parameter
-f : ```vendor/bin/pest --filter "$@"```

```
pf CoreConfig
```

#### Dusk - Browser Testing

See: https://laravel.com/docs/10.x/dusk

**Important:**
You should run dusk on a separate system created for the dusk tests.
If you don't do it, notice the following:

**When running tests, Dusk will back up your .env file and rename your Dusk environment to .env.
Once the tests have completed, your .env file will be restored. That's why you should not run
other processes on the same system.**

Requirements:

```
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
```

Dusk can be called with phpunit parameters. So if you want to call a specific class, use this format:

```
php artisan dusk --filter ProductDetailViewTest
```

to run whole dusk tests enter

```
php artisan dusk
```

#### Rendering Mailables

Test with designer permissions

```
https://mercy.test/test-mail-template
```

### Useful tools

#### Redis

Check what's going on in redis cache

```
redis-cli monitor
```

### ide-helper

For all in one ide-helper stuff just run ```./ui.sh``` and press ```[i]```.
Otherwise, here is a quick overview:

Clearing ```bootstrap/compiled.php``` first by:

```
php artisan clear-compiled
```

#### Facades

Generate the facades:

```
php artisan clear-compiled
php artisan ide-helper:generate
```

#### Models

Using the --write-mixin (-M) option will only add a mixin tag to your Model file, writing the rest
in (```_ide_helper_models.php```). The class name will be different from the model, avoiding the IDE duplicate
annoyance.

```
php artisan ide-helper:models -M
```

#### Meta

Meta means resolve containers like ```app('events')->fire();```

```
php artisan ide-helper:meta
```

### Provided Console Commands

Generate a password hash. This command will ask you for a secret.
Optionally you can also enter a user id by --user=xxx to update the password in db.

```
password:generate
```

