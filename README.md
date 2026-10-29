## Mercy Scaffold

[Mercy Scaffold](https://github.com/aklebe-laravel/mercy-scaffold) is a Laravel scaffold to start web projects
based on **modules** and **themes**: the scaffold provides the environment (Docker, install, build, deployment),
your logic lives in modules, your layout in themes, your project data in business imports.

The scaffold itself contains almost no application code. A project made with Mercy is defined by

- its **project repository**, cloned as `project/`: config (name, domain, required modules and themes, ...)
  and business imports (project-specific database data), see [Project](#project),
- the modules in `/Modules` and themes in `/themes` (cloned by the setup).

### Features

- Full installation process for your dev environment with one command:
    - Docker containers: the main app, MariaDB, Redis, Mailpit (dev only)
    - clone all required modules and themes, composer install
    - generate `.env`, auto ports (several projects on one machine without port collisions)
    - create the hosts in Nginx Proxy Manager by API (optional)
    - migrate and terraform (seed) the deployment data of all modules and your business imports
    - build the frontend
- Build a production Docker image and push it to a registry (GitHub, self-hosted Gitea, ...)
- Install/update on production by the [Mercy-Installer](#install-on-production)
- Up-to-date stack: Laravel 13, PHP 8.5, Livewire 4, Tailwind v4, Vite, npm workspaces for themes
- Merges the `composer.json` files of `/Modules/*` and `/themes/*` (wikimedia/composer-merge-plugin)

Base modules:

| Module                                                           | Meaning                                                                  |
|------------------------------------------------------------------|--------------------------------------------------------------------------|
| SystemBase                                                       | base services, helpers and providers used by all modules                 |
| [DeployEnv](https://github.com/aklebe-laravel/deploy-env-module) | deployments/terraforming (seeding), business imports, `mercy:*` commands |
| WebsiteBase                                                      | base of the website (layout, navigation, ...)                            |
| [Acl](https://github.com/aklebe-laravel/acl-module)              | permissions and user groups stored in the database                       |
| [DataTable](https://github.com/aklebe-laravel/data-table-module) | datatables using Livewire and Alpine.js                                  |
| [Form](https://github.com/aklebe-laravel/form-module)            | easy configured forms                                                    |

Modules are based on [nwidart/laravel-modules](https://github.com/nWidart/laravel-modules),
Livewire in modules on [mhmiton/laravel-modules-livewire](https://github.com/mhmiton/laravel-modules-livewire),
themes on [alizharb/laravel-themer](https://github.com/alizharb/laravel-themer).
The default theme is `mercy-blank`.

### Folder structure

| Path                      | Meaning                                                                            |
|---------------------------|------------------------------------------------------------------------------------|
| `mercy.php`               | dev installer: `php mercy.php install`                                             |
| `build.php`               | builds the production image: `php build.php create`                                |
| `project/`                | **your project repository**: configs and business imports, see [Project](#project) |
| `resources/setup/`        | templates of the scaffold: new project, `setup-*.env`, `.env.minimal`, `core.yaml` |
| `storage/app/last-setup/` | generated: merged configs and envs of this machine, never edit (not in git)        |
| `Modules/`                | modules (cloned by `setup.requires`, enabled in `modules_statuses.json`)           |
| `themes/`                 | themes (cloned by `setup.requires`, npm workspaces)                                |
| `install/project-root/`   | files copied to the project root by the installer                                  |
| `docker/`                 | Dockerfile, nginx/php config and `start-container` of the app container            |
| `storage/docker-builds/`  | build folder of the production image                                               |

### Prerequisites

Installed on your machine:

- Docker with the compose plugin (your user in the group `docker`)
- Composer 2.9, `git`, `unzip`
- PHP 8.5 with the extensions curl, zip, mbstring, xml, gd, intl, ldap, bcmath (Ubuntu: PPA `ondrej/php`,
  `sudo apt install php8.5-cli php8.5-curl php8.5-zip php8.5-mbstring php8.5-xml php8.5-gd php8.5-intl php8.5-ldap php8.5-bcmath`).
  The production build checks the host PHP version, it has to match the image (8.5).
- Node.js 22 with npm, only for the production build (`npm ci` and `npm run build` run on the host)
- An SSH key with access to your git server (to clone modules/themes), see `ssh` in `setup.yaml`.
  The install prepares git and ssh of this machine itself (step `setup_host`, also `php mercy.php host:setup`):
  it creates a missing deploy key, adds the hosts of `ssh.known_hosts` to `~/.ssh/known_hosts` (only with a known
  fingerprint, github.com is built in) and tests the access. The only manual step: add the shown public key at the git server.
- _[Optional]_ Nginx Proxy Manager, see `npm` in `setup.yaml`. The app container joins the Docker network
  `proxy-gateway` (created by the install if missing). `npm.forward: network` for a proxy container in this
  network, `npm.forward: host` for a proxy on another machine.
- For a push to a registry: `docker login <registry>` (GitHub: `ghcr.io` with a classic token, `write:packages`)

Tested on a small VM: Ubuntu 24.04 LTS, 1 CPU core, 2 GiB memory, 32 GB disk (dev install, dev update, production build and push).

### Use your own git server (mirror of GitHub)

The code always uses the GitHub urls (`https://github.com/aklebe-laravel/...`, `git@github.com:aklebe-laravel/...`).
To clone from your own server instead (e.g. a Gitea that mirrors to GitHub), put this into the project config,
best into the config of your network (e.g. `project/config/networks/home.yaml`), so every instance there gets it:

```yaml
git:
  url_rewrites:
    - base: "gitea@git.example.com:aklebe-laravel/"
      instead_of:
        - "https://github.com/aklebe-laravel/"
        - "git@github.com:aklebe-laravel/"
ssh:
  known_hosts:
    - github.com
    - git.example.com
  fingerprints:
    git.example.com: 'SHA256:...'   # on the server: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Then `install`/`update`/`build` (step `setup_host`) set the git `insteadOf` rewrites in your global git config, add
the server to `~/.ssh/known_hosts` and test the access. Without `url_rewrites` everything comes from GitHub.

One key per machine: the deploy key (`ssh.key`). The containers use it, and so do `composer install` and the
build on this machine (the deployment sets `GIT_SSH_COMMAND`). Your own git commands keep your own ssh key.

### Install the dev environment

1) Clone this project
   ```
   git clone https://github.com/aklebe-laravel/mercy-scaffold.git .
   ```
2) **_[Important]_ Your project**
    - existing project: clone your project repository as `project/` and create its `config/secrets.yaml`
      ```
      git clone <your-project-repo> project
      ```
    - new project: `composer install && php mercy.php project:init`, then edit the files in `project/config/`
    - `composer install` in a fresh checkout only installs the deployment tool: it skips `artisan package:discover`
      until `php mercy.php install` has cloned the core modules (message "Mercy core modules are not installed yet")
3) Install
   ```
   composer install
   php mercy.php install
   ```
   Show all steps by `php mercy.php install --info`. Continue at a specific step (after an error)
   by `php mercy.php install 12` (step number or name).

The install runs these steps: copy root files, prepare `.env.minimal`, copy the SSH files for Docker,
clone base modules and theme, composer update, create `.env` (from `setup-local.env`), build and start the
containers, `key:generate`, `storage:link`, sync Nginx Proxy Manager, clone `requires`,
`mercy:app update`, `mercy:app migrate`, health check and finally a summary (`mercy:info`) with URLs and ports.

### After the install

The install contains the data of the modules, but not the data of your project. Typical next steps:

```
# 1) users and groups from LDAP (only with ldap.enabled in setup.yaml)
sail artisan ldap:sync-all

# 2) your business imports (link users to groups, servers, ...), again after changing them
sail artisan deploy-env:terraform-modules --module_name=local:business-imports --force
```

The order matters if business imports update users with `can_create => false`: they only find users that
the LDAP sync has already created. On production use `docker compose exec mercy.app php artisan ...` instead of `sail artisan ...`.

### Project

Everything that makes your project different from the scaffold lives in **one folder, `project/`**, an own (private) git repository. The scaffold ignores it and stays generic.
`php mercy.php project:init` creates a new
one from the template in `resources/setup/project/`.

```
project/
  config/
    setup.yaml             base config, versioned
    dev.yaml               only the differences of the dev environment
    build.yaml             only the differences of the production image (release number)
    prod.yaml              only the differences of the production server (used by the Mercy-Installer)
    secrets.yaml           passwords and keys of this machine, NOT versioned
    <stage>.secrets.yaml   optional, NOT versioned
  business_imports/        project data, see Business Imports (their secrets: env vars in config/secrets.yaml)
  README.md
```

Merge order per stage: `setup.yaml` → `<stage>.yaml` → `secrets.yaml` → `<stage>.secrets.yaml`.
Maps are merged key by key, lists (like `requires`) are replaced as a whole.

Every yaml can inherit others with `extends` (paths relative to the file, the inherited files come first).
That separates the three levels of a config: **product** (`setup.yaml`: modules, theme, ...), **network/site** (pfSense, NPM, DNS, LDAP, registry, shared by several instances) and **instance**
(domain, ports, release, the stage file itself). Keep it at these three levels.

```yaml
# project/config/prod.yaml
extends:
  - setup.yaml
  - networks/home.yaml
kernel:
  domain: "proxtop.example.com"
  version: "2.0.1"
```

A stage file without `extends` inherits `setup.yaml`. `php mercy.php config` shows the chain and the origin
of every value.

Before every command `php mercy.php` writes the dev stage to `storage/app/last-setup/setup.yaml` and the
build stage to `setup-build.yaml`, so **edit the project, never the generated files**.

One place to look at the result, with the origin of every value (secrets masked):

```
php mercy.php config                 # dev stage
php mercy.php config npm --stage=build
php mercy.php config --all           # also the keys of the template that are not set
```

### Config files

| File                                   | Meaning                                                                           |
|----------------------------------------|-----------------------------------------------------------------------------------|
| `project/config/*.yaml`                | your project (kernel name/env/domain/theme, git, ports, requires, npm, ssh, ldap) |
| `resources/setup/project/`             | template of a new project (`project:init`)                                        |
| `resources/setup/setup-local.env`      | template of `.env` for the dev environment                                        |
| `resources/setup/setup-production.env` | template of `.env` for production                                                 |
| `resources/setup/.env.minimal`         | minimal env (sqlite in memory, array cache) to run artisan during install/build   |
| `resources/setup/core.yaml`            | Mercy core modules and default theme (belongs to the scaffold version)            |
| `storage/app/last-setup/`              | generated configs and envs of this machine (ports and keys stay fixed there)      |

#### Instance identity (project name)

`APP_INSTANCE_KEY` and `COMPOSE_PROJECT_NAME` are calculated once (from name, domain, git and ports)
and then **kept**, even if `setup.yaml` changes or `setup-local.env` was deleted (the value is then taken
from the project's `.env`). Docker volumes (database!) belong to this project name: a new name would start
a new, empty instance. If the config would give a different value, the install shows a warning.

To start a really fresh instance on purpose, delete both lines (or the whole file) in `.env`
and in `storage/app/last-setup/setup-local.env`, then run the install again.

Important sections of `setup.yaml`:

- `kernel`: `name` (image name and container prefix), `env`, `domain`, `theme`,
  `debug` (full console output), `dev_mode` (composer/optimize behaviour)
- `provisioning.auto_port_start`: use a different start value per project to avoid port collisions
- `requires`: the modules and themes to clone, see the [DeployEnv README](Modules/DeployEnv/README.md#require-modules-and-themes)
- `npm`: Nginx Proxy Manager API and hosts (`enabled: false` to skip)
- `ssh`: deploy key and the known hosts provided to the container

#### Versions

A version belongs to a built image, not to an environment:

| Where      | Version                                                                                        |
|------------|------------------------------------------------------------------------------------------------|
| dev        | no fixed number: `git describe` of this project, e.g. `v2.0.1-rc1-3-g1a2b3c4-dirty`            |
| build      | `kernel.version` in `project/config/build.yaml`: the release number (image tag, `APP_VERSION`) |
| production | `kernel.version` in `project/config/prod.yaml`: the release to run                             |

So dev never pretends to be a release. `sail artisan mercy:info` and `APP_VERSION` show what really runs.
A `kernel.version` in `setup.yaml` or `dev.yaml` would override the git version, keep it in `build.yaml` and `prod.yaml`.

### Dev tools and flows

| Task                                                   | Command                                                                                  |
|--------------------------------------------------------|------------------------------------------------------------------------------------------|
| Rebuild containers                                     | `sail build --no-cache`                                                                  |
| Start containers                                       | `sail up -d`                                                                             |
| Run Vite dev server                                    | `sail npm run dev`                                                                       |
| Shell in the app container                             | `sail shell`                                                                             |
| Update composer, npm, clear caches, build frontend     | `sail artisan mercy:app update`                                                          |
| Clear caches and views                                 | `sail artisan mercy:app cache,view`                                                      |
| Build frontend (incl. clear caches)                    | `sail artisan mercy:app build-frontend`                                                  |
| Clone/update the modules and themes of `requires`      | `sail artisan mercy:app require`                                                         |
| Migrate and terraform all modules and business imports | `sail artisan mercy:app migrate`                                                         |
| Dev all in one if many things heappend                 | `sail artisan mercy:app migrate,build-frontend,cache,view`                               |
| Terraform all modules and business imports (new only)  | `sail artisan deploy-env:terraform-modules`                                              |
| Run business imports again (after changing your data)  | `sail artisan deploy-env:terraform-modules --module_name=local:business-imports --force` |
| Important env vars, hosts, ports and URLs              | `sail artisan mercy:info`                                                                |
| List modules by priority                               | `sail artisan deploy-env:module-info`                                                    |

All `mercy:app` services and `deploy-env:*` commands are described in the [DeployEnv README](Modules/DeployEnv/README.md).

### Create modules, forms and datatables

Create a new module from the stubs of DeployEnv:

```
sail artisan deploy-env:make-module MyModule
```

If the modules `Form` and `DataTable` are installed, create the model, form and datatable classes:

```
sail artisan deploy-env:former MyModule --classes=country,some-thing,AnyThing
```

This creates per class name (existing files are not changed):

```
Modules/MyModule/app/Models/Country.php
Modules/MyModule/app/Forms/Country.php
Modules/MyModule/app/Http/Livewire/Form/Country.php
Modules/MyModule/app/Http/Livewire/DataTable/Country.php
```

Without `--classes`, datatables and forms are created for every model of the module.
More files can be created by other modules listening to the event `DeployEnvFormer`.

### Business Imports

Business imports are the **project-specific data** of your instance (users and their groups, servers,
templates, ...). Modules bring their own base data, business imports bring yours, without changing any module.
They live in the project repository (`project/business_imports`), not in the scaffold and not in the image.
Secrets used by imports are env vars like all other secrets: set in `project/config/secrets.yaml` under `env`
(not versioned), mapped in the config of a module (`'token' => env('MY_API_TOKEN')`) and read in the import file
with `config('my-module.token')`. Not with `env()`: once the config is cached, `env()` returns nothing there.

The folder `project/business_imports` is linked to `storage/app/imports` inside the container:

```
project/business_imports/
└── module-deploy-env/
    ├── a-2026-08-04.php          # import config, any unique name, all files run sorted by name
    └── 0002/                     # deployment ident used in the config
        └── models/               # cmd "models"
            ├── servers.php       # model definition, any unique name
            └── users.php
```

The import config uses the same format as a module's `config/module-deploy-env.php`:

```php
return [
    'deployments' => [
        // ident, runs once (like a migration) unless --force
        '0002' => [
            [
                'cmd'     => 'models',
                'sources' => ['servers.php', 'users.php'],
            ],
        ],
    ],
];
```

A model definition finds models by `uniques`, creates/updates them and syncs their relations:

```php
return [
    'model'      => \App\Models\User::class,
    'uniques'    => ['name'],
    'can_create' => false,   // only update users that already exist (like imported by LDAP)
    'can_update' => true,
    'relations'  => [
        'aclGroups' => ['method' => 'aclGroups', 'columns' => 'name', 'auto_delete' => false],
    ],
    // the key 'data' is required, rows outside of it are ignored
    'data'       => [
        [
            // multiple users with the same data (comma separated or array)
            'name'            => 'david,uwe,frank',
            'is_enabled'      => 1,
            '#sync_relations' => [
                'aclGroups' => ['Members'],
            ],
        ],
    ],
];
```

Run the imports:

```
# with everything else (only deployments not done yet)
sail artisan deploy-env:terraform-modules

# business imports only, again (after changing your data)
sail artisan deploy-env:terraform-modules --module_name=local:business-imports --force
```

All options (`can_create`, `can_update`, `ignore_update_fields`, `auto_delete`, `unique_separator`,
relation types, `raw_sql`, `artisan`, ...) are described in the
[DeployEnv README](Modules/DeployEnv/README.md#model-definition-cmd-models).

### Build the image for production

Set the release number in `project/config/build.yaml` first (`kernel.version`, e.g. `2.0.1-rc1`),
check `git` and `build_steps` (`php build.php config --stage=build`). Then run **in your dev folder** (takes several minutes):

```
php build.php create
```

Like the install, `php build.php create --info` lists the steps and `php build.php create <step>` continues at a step.

The build runs in `storage/docker-builds/prod-build`:

1. check the host PHP version, clean the build folder
2. git clone the scaffold into the build folder
3. use the build stage of your project (`setup-build.yaml`) as `setup.yaml` of the build
4. check platform requirements, copy root files, create `.env` from `setup-production.env`
5. fetch base modules and theme, `composer install --no-dev`, fetch `requires` (`mercy:app require`)
6. composer install of the module dependencies (optimized autoloader)
7. `npm ci`, `deploy-env:build-mercy-assets`, `npm run build`
8. remove build-only files (`.env`, `node_modules`, setup configs)
9. build the Docker image, save it as `.tar.gz`
10. _[Optional]_ create a bundle (`build_steps.create_bundle`)
11. _[Optional]_ push to the registry (`build_steps.use_registry`)

Business imports are not part of the image, they are provided on the production server.

### Install on production

Use the **Mercy-Installer** on your production server and follow its README. It has the same layout as
the scaffold (`project/`, `resources/setup/`, `storage/app/last-setup/`) and uses the same project repository (stage `prod`). Business imports run by:

```
docker compose exec mercy.app php artisan deploy-env:terraform-modules --module_name=local:business-imports --force
```

### Docker maintenance

#### Docker config

Recommended `/etc/docker/daemon.json`:

```json
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "builder": {
        "gc": {
            "enabled": true,
            "defaultKeepStorage": "50GB"
        }
    },
    "features": {
        "buildkit": true
    }
}
```

#### Remove everything

```
# containers, networks and volumes (the DATABASE) of this folder, images built here
php mercy.php destroy

# also the pulled images (app image, mariadb, redis) and/or all files of the folder
php mercy.php destroy --images --files
```

`destroy` uses the docker project name of the `.env` and asks you to type it. With `--files` it refuses
as long as a git repo in the folder (scaffold, `project/`, modules, themes) has uncommitted or unpushed changes.
`--force` skips both checks (for scripts).

### Tips

#### sail alias

```
echo "alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'" >> ~/.bashrc
```
