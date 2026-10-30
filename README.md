# Mercy Scaffold

**Mercy** is a modular foundation for Laravel applications. You install a complete dev environment with one
command, build a production Docker image with a second, and install or update it on a server with a third.

The scaffold provides the environment and contains almost no application code. Everything else lives in its own
repositories:

| Part                                                                           | Contains                                                            |
|--------------------------------------------------------------------------------|---------------------------------------------------------------------|
| **Mercy Scaffold** (this repository)                                           | Laravel app shell, Docker setup, the `./mercy` CLI                  |
| **Modules** (`Modules/`)                                                       | your logic: models, Livewire components, routes, deployments        |
| **Themes** (`themes/`)                                                         | your layout: Blade views, Tailwind, assets                          |
| **Project repository** (`project/`)                                            | what makes your product unique: config per stage and instance, data |
| [mercy-php-deployment](https://github.com/aklebe-laravel/mercy-php-deployment) | the library behind `./mercy`: install, update, build steps          |
| [mercy-installer](https://github.com/aklebe-laravel/mercy-installer)           | `./mercy install` / `update` of the image on a production server    |

A product made with Mercy is therefore **one project repository plus the modules and themes it lists**. The
scaffold stays generic and can be updated independently of your product.

## Contents

- [Features](#features)
- [Modules and themes](#modules-and-themes)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [The `./mercy` CLI](#the-mercy-cli)
- [Project repository](#project-repository)
- [Business imports](#business-imports)
- [Workflows](#workflows)
- [Build the production image](#build-the-production-image)
- [Production](#production)
- [Using your own git server](#using-your-own-git-server)
- [Versions and releases](#versions-and-releases)
- [Development reference](#development-reference)
- [Folder structure](#folder-structure)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features

**Environment**

- Complete dev environment with one command (`./mercy install`): app container (PHP 8.5, Nginx, PHP-FPM, Reverb,
  queue and scheduler under supervisor), MariaDB 11, Redis, Mailpit
- Modules and themes are cloned and wired automatically; their `composer.json` files are merged into the app (`wikimedia/composer-merge-plugin`), their `docker/supervisord.conf` is included
- Automatic ports: several projects and instances run side by side on one machine without collisions
- Optional: proxy hosts and certificates in Nginx Proxy Manager are created and kept up to date by API
- The machine is prepared by the tool itself (`host:setup`): git rewrites, `known_hosts` checked against
  fingerprints, deploy key, access test, bash tab completion

**Configuration**

- One project repository instead of copied folders: product, network and instance are separate layers
- Mercy defaults as the lowest layer: project files contain only their differences, new Mercy versions bring new
  settings without touching a project file
- Unknown or renamed keys are reported before every command; `./mercy config` shows every value and where it comes from
- Secrets stay on the machine (not versioned) and are masked in every output

**Build and deployment**

- Reproducible production image from releases (tags) or, for test systems, from a branch
- `build.lock.yaml` in the image: exact commit of the scaffold, every module, theme and library
- Push to any registry (GitHub `ghcr.io`, Gitea, ...), optional offline bundle
- Production install and update with the [Mercy-Installer](https://github.com/aklebe-laravel/mercy-installer):
  switch releases by changing one line
- Migrations, module deployments and your project data run on every install and update
- Safe teardown (`./mercy destroy`): asks for confirmation, refuses to delete folders with unpushed git work

**Stack:** Laravel 13, PHP 8.5, Livewire 4, Tailwind CSS 4, Vite, npm workspaces for themes,
[nwidart/laravel-modules](https://github.com/nWidart/laravel-modules),
[mhmiton/laravel-modules-livewire](https://github.com/mhmiton/laravel-modules-livewire),
[alizharb/laravel-themer](https://github.com/alizharb/laravel-themer).

## Modules and themes

All modules and themes are separate repositories in [aklebe-laravel](https://github.com/aklebe-laravel), MIT licensed. **Base** modules come with every installation (released versions,
see [Workflows](#workflows)); the others are added to
`requires` of your project.

| Module / theme                                                               | Included | Description                                                                                                             |
|------------------------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------------------------|
| [system-base-module](https://github.com/aklebe-laravel/system-base-module)   | core     | foundation for all modules: base service providers and Livewire components, config merging, caching, helpers, schedules |
| [deploy-env-module](https://github.com/aklebe-laravel/deploy-env-module)     | core     | deployments (seeding) of modules and business imports, `mercy:*` and `deploy-env:*` commands, module generator          |
| [website-base-module](https://github.com/aklebe-laravel/website-base-module) | base     | multi-store website: navigation, CMS pages, core config in the database, data management of models, notifications       |
| [acl-module](https://github.com/aklebe-laravel/acl-module)                   | base     | access control: user groups and resources in the database, optional users and groups from LDAP                          |
| [data-table-module](https://github.com/aklebe-laravel/data-table-module)     | base     | Livewire data tables for models and their relations: sorting, filters, one class per table                              |
| [form-module](https://github.com/aklebe-laravel/form-module)                 | base     | Livewire forms for models and their relations: element configuration, validation, events                                |
| [central-ui-module](https://github.com/aklebe-laravel/central-ui-module)     | optional | web desktop for Proxmox: VM cards with status and start/stop, schedules, ACL per VM group, WireGuard peers on pfSense   |
| [mercy-blank-theme](https://github.com/aklebe-laravel/mercy-blank-theme)     | core     | default theme and parent of project themes (Tailwind 4)                                                                 |
| [central-ui-theme](https://github.com/aklebe-laravel/central-ui-theme)       | optional | admin theme for central-ui-module, child theme of mercy-blank                                                           |

**Core** modules and the default theme are defined by the scaffold itself (`resources/setup/core.yaml`) and are
cloned first, because the commands that clone everything else live in DeployEnv. **Base** modules are listed in the
Mercy defaults (`base_requires`). An entry with the same name in your `requires` wins over both.

Create your own module with `sail artisan deploy-env:make-module MyModule`, see [Development reference](#development-reference).
An example of a complete product is [proxtop-web](https://github.com/aklebe-proxtop/proxtop-web).

## Requirements

On the machine that runs the dev environment or builds the image:

| Requirement                     | Notes                                                                                                                                    |
|---------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| Docker with the compose plugin  | your user in the group `docker`                                                                                                          |
| PHP 8.5 CLI                     | extensions curl, zip, mbstring, xml, gd, intl, ldap, bcmath (Ubuntu: PPA `ondrej/php`). The build checks that it matches the image (8.5) |
| Composer 2.9, `git`, `unzip`    |                                                                                                                                          |
| Node.js 22 with npm             | only for `./mercy build` (`npm ci` and `npm run build` run on the host)                                                                  |
| SSH access to your git server   | the install creates a deploy key if missing and shows it; you add it once at GitHub / your git server                                    |
| _Optional:_ Nginx Proxy Manager | see `npm` in the [Mercy defaults](https://github.com/aklebe-laravel/mercy-php-deployment/blob/master/resources/defaults/setup.yaml)      |
| _Optional:_ registry login      | for `./mercy build` with push; the build asks for user and token (GitHub: `ghcr.io`, classic token with `write:packages`)                |

Ubuntu packages for PHP:

```bash
sudo apt install php8.5-cli php8.5-curl php8.5-zip php8.5-mbstring php8.5-xml php8.5-gd php8.5-intl php8.5-ldap php8.5-bcmath
```

Tested on Ubuntu 24.04 LTS with 1 CPU core, 2 GiB memory and 32 GB disk (dev install, dev update, build and push).

## Quick start

```bash
# 1. the scaffold, on its latest release
git clone https://github.com/aklebe-laravel/mercy-scaffold.git my-app && cd my-app
git checkout "$(git describe --tags --abbrev=0)"

# 2. your project repository as project/ ...
git clone <your-project-repository> project
cp project/config/secrets.example.yaml project/config/secrets.yaml   # if your project has one, then fill it in
# ... or a new project from the template
composer install && ./mercy project:init

# 3. install
composer install
./mercy install                  # with instances: ./mercy install --instance=<name>
```

The install prepares the machine, clones the modules and themes, creates `.env`, builds and starts the containers,
runs migrations and deployments and ends with a summary of URLs and ports. Open a new terminal afterwards to get
tab completion (`./mercy install --instance=<tab>`).

Then load your project data:

```bash
sail artisan ldap:sync-all          # only with ldap.enabled: users and groups first
sail artisan deploy-env:terraform-modules --module_name=local:business-imports --force
```

`./mercy` without a command tells you at any time where this installation stands and what to do next.

A fresh checkout's `composer install` only installs the deployment tool and skips `artisan package:discover` until
`./mercy install` has cloned the core modules ("Mercy core modules are not installed yet" is expected).

## The `./mercy` CLI

`./mercy` works like Laravel's `artisan` (also `php mercy`; tab completion only with `./mercy`).

| Command                   | Purpose                                                                                                    |
|---------------------------|------------------------------------------------------------------------------------------------------------|
| `./mercy`                 | status: project, instance, config warnings, secrets, containers, URL and the next step (read only)         |
| `./mercy install`         | full install of the dev environment                                                                        |
| `./mercy update`          | refresh an existing dev environment (after `git pull`, config changes, new modules); keeps keys and data   |
| `./mercy build`           | build the production image, see [Build](#build-the-production-image)                                       |
| `./mercy config [filter]` | effective config with the origin of every value (`--stage`, `--all`, `--redundant`, `--instance`)          |
| `./mercy project:init`    | create `project/` from the template                                                                        |
| `./mercy host:setup`      | prepare git and ssh of this machine (also the first step of install, update, build)                        |
| `./mercy library:sync`    | refresh a library from your local folder, see [Workflows](#workflows)                                      |
| `./mercy destroy`         | remove containers, volumes (the database!) and proxy hosts of this folder, see [Maintenance](#maintenance) |

Every command that changes something is a list of named steps:

```bash
./mercy install --info          # list the steps
./mercy install 12              # continue at step 12 (number or name), e.g. after fixing an error
```

Global option `--instance=<name>`: chosen once per installation and remembered in `project/.instance`.
The step reference of every command is in the
[mercy-php-deployment README](https://github.com/aklebe-laravel/mercy-php-deployment#commands-and-steps).

## Project repository

Everything that makes your product different lives in **one folder, `project/`**, an own git repository (private if it contains your hosts). The scaffold ignores it. `./mercy project:init` creates one
from
`resources/setup/project/`.

```
project/
  config/
    setup.yaml               product: name, image, theme, modules, env of modules        (versioned)
    networks/<name>.yaml     network/site: git server, NPM, LDAP, DNS                    (versioned)
    instances/<name>.yaml    one installation: domain, ip, ports, release                (versioned)
    dev.yaml                 differences of the dev stage                                (versioned)
    build.yaml               differences of the image: release number                    (versioned)
    prod.yaml                differences of the production stage: release to run         (versioned)
    secrets.yaml             passwords and tokens of this machine                        (NOT versioned)
    local.yaml               branches and libraries of this machine                      (NOT versioned)
  business_imports/          project data, see Business imports
  README.md
```

### Layers

Every stage (`dev`, `build`, `prod`) merges, from lowest to highest:

1. **Mercy defaults** (`resources/defaults/` of mercy-php-deployment): every key with its default and an explanation
2. `setup.yaml` and the files it `extends` (e.g. a network)
3. the stage file (`dev.yaml`, `build.yaml`, `prod.yaml`)
4. the instance (`instances/<name>.yaml`, usually extends its network)
5. `secrets.yaml`, `<stage>.secrets.yaml`, `local.yaml`

Maps are merged key by key, lists (like `requires`) are replaced as a whole. Every file can inherit others with
`extends: [ setup.yaml, networks/home.yaml ]` (paths relative to the file, cycles are an error); a stage file without
`extends` inherits `setup.yaml`. The build stage extends the dev stage, so an image is never built with the domain
of a production instance.

Keep the three levels apart: **product** (`setup.yaml`), **network** (`networks/`, shared by all instances there), **instance** (domain, ports, release). A structural change is then made in one place
and every instance inherits it.

```yaml
# project/config/instances/vm-dev.yaml
extends: [ ../networks/home.yaml ]
kernel:
  domain: "my-product.dev.example.com"
  ip: "192.0.2.75"
provisioning:
  auto_port_start: 27500        # several instances on one machine: own port range
```

As soon as `config/instances/` contains files, every command needs an instance, so nothing ever runs with the wrong
config. The first line of every command names project, instance and stage.

### Inspecting the config

```bash
./mercy config                     # dev stage, only the values the project sets
./mercy config npm --stage=build   # one section of another stage
./mercy config --all               # including the Mercy defaults
./mercy config --redundant         # project values that equal a default and can be removed
```

Before every command the result is written to `storage/app/last-setup/` (generated, never edit it). Unknown keys (typos, old names) are reported; renamed keys are moved to their new name with a
warning.

### Secrets

`secrets.yaml` exists only on the machine. Keep a copy in your password manager. Values that may be versioned (e.g. the
password of a local dev tool) go into a file ending with `-secrets.yaml` (e.g. `shared-secrets.yaml`), inherited with
`extends`: masked like secrets, but committed. Never for production secrets.

### Important sections

| Section        | Meaning                                                                                                                                   |
|----------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `kernel`       | `name` (container prefix, image), `image`, `domain`, `ip`, `theme`, `version`, `debug`, `dev_mode`                                        |
| `requires`     | your modules and themes, see [Require modules and themes](https://github.com/aklebe-laravel/deploy-env-module#require-modules-and-themes) |
| `env`          | free env vars of your project and its modules, written 1:1 into `.env`                                                                    |
| `git`          | registry of the image, `url_rewrites` for an own git server, branches for development                                                     |
| `provisioning` | `auto_port_start`: first port of this instance                                                                                            |
| `npm`          | Nginx Proxy Manager: API, hosts, `forward` (`network` or `host`)                                                                          |
| `ssh`          | deploy key, known hosts and their fingerprints                                                                                            |
| `ldap`         | LDAP server of the Acl module                                                                                                             |
| `build_steps`  | build options: `branch`, `use_registry`, `create_bundle`, ...                                                                             |

All keys with explanations: [Mercy defaults](https://github.com/aklebe-laravel/mercy-php-deployment/blob/master/resources/defaults/setup.yaml).

### Instance identity

`COMPOSE_PROJECT_NAME`, `APP_INSTANCE_KEY` and the auto ports are calculated on the first install and then **kept**,
even if the config changes. Docker volumes (the database) belong to the project name, so a new name would mean a new,
empty instance; the install only warns if the config would give another value. New ports: change
`provisioning.auto_port_start`. A deliberately fresh instance: remove both keys from `.env` and
`storage/app/last-setup/setup-local.env`, then install again.

## Business imports

Business imports are the **data of your product** (users and their groups, servers, templates, navigation, ...).
Modules bring their own base data; business imports bring yours, without changing a module. They live in
`project/business_imports/`, not in the image, and are linked to `storage/app/imports` in the container.

```
project/business_imports/
└── module-deploy-env/
    ├── a-my-product.php       # import config, any unique name, all files run sorted by name
    └── 0002/                  # deployment ident used in the config
        └── models/            # cmd "models"
            ├── servers.php
            └── users.php
```

The import config has the format of a module's `config/module-deploy-env.php`:

```php
return [
    'deployments' => [
        // ident, runs once (like a migration) unless --force
        '0002' => [
            ['cmd' => 'models', 'sources' => ['servers.php', 'users.php']],
        ],
    ],
];
```

A model definition finds models by `uniques`, creates or updates them and syncs their relations:

```php
return [
    'model'      => \App\Models\User::class,
    'uniques'    => ['name'],
    'can_create' => false,   // only update users that already exist (e.g. imported from LDAP)
    'can_update' => true,
    'relations'  => [
        'aclGroups' => ['method' => 'aclGroups', 'columns' => 'name', 'auto_delete' => false],
    ],
    'data'       => [
        [
            'name'            => 'david,uwe,frank',   // several rows with the same data
            'is_enabled'      => 1,
            '#sync_relations' => ['aclGroups' => ['Members']],
        ],
    ],
];
```

Run them (again after changing your data):

```bash
sail artisan deploy-env:terraform-modules --module_name=local:business-imports --force
```

Order matters: imports with `can_create => false` only find users the LDAP sync has already created, so run
`ldap:sync-all` first. All options (`ignore_update_fields`, `unique_separator`, relation types, `raw_sql`, `artisan`, ...):
[DeployEnv README](https://github.com/aklebe-laravel/deploy-env-module#model-definition-cmd-models).

**Secrets in imports** are env vars like all other secrets: `env: { MY_API_TOKEN: "..." }` in `secrets.yaml`, mapped in
the module config (`'token' => env('MY_API_TOKEN')`), read in the import with `config('my-module.token')`. Never `env()`
in an import: once the config is cached it returns nothing there.

## Workflows

One rule: **what is checked out in your dev folder stays**. Your IDE switches branches; `./mercy update` only pulls.
The configs decide what *new* clones start with and what the build takes.

| Repository                         | Comes from                                                         | Change it with                                        |
|------------------------------------|--------------------------------------------------------------------|-------------------------------------------------------|
| scaffold, installer                | your `git clone` (tag or branch)                                   | `git checkout` / IDE                                  |
| Mercy core and base modules, theme | `base_requires` of the Mercy defaults: latest release (`^2.0`)     | `git.branch` / `git.branches` in `local.yaml`         |
| your modules and themes            | `requires` of your project (`branch: master` or `version: "^1.0"`) | IDE; for new clones `git.branch` / `git.branches`     |
| libraries (`mercy-php-deployment`) | `composer.lock` (released tags)                                    | `git.library_paths` or `git.branches` in `local.yaml` |
| the image (`./mercy build`)        | releases                                                           | `build_steps.branch`                                  |

`project/config/local.yaml` is not versioned and belongs to this machine only. `./mercy` shows what is active.

**Build your product on the Mercy releases** (you work on your own modules only): the [Quick start](#quick-start)
is all you need. Your modules come from `requires`, Mercy's from its tags.

**Work on the Mercy base itself** (all repositories on `master`):

```yaml
# project/config/local.yaml
git:
  branch: master
```

Check out the scaffold on `master`, then `./mercy update`. New clones and clones on a tag move to `master`, clones on a
branch keep it.

**A feature across several repositories:** switch them to `feature-x` in the IDE, nothing to configure. On a fresh
machine: `git.branch: feature-x` (repositories without that branch take `master` or their release).

**Develop a library next to the project** (its own IDE project, any branch):

```yaml
git:
  library_paths:
    mercy-php-deployment: ../MercyPhpDeployment
```

`./mercy update` copies it into `storage/app/library-branch/` (the container only sees the scaffold folder); after a
change in the library run `./mercy library:sync`. A pushed branch instead: `git.branches: { mercy-php-deployment: feature-x }`. **Do not commit `composer.lock` while one of these is active**;`./mercy`
shows a red warning if the lock points to a
local library.

**Test image from a branch** (staging, not a release):

```yaml
# project/config/instances/vm-dev.yaml (the instance that builds)
build_steps:
  branch: feature-x
```

`./mercy build` takes scaffold, modules, themes and libraries from `feature-x` where they have it (the rest from their
release) and tags the image `<version>-feature-x`. Run it on the test server with `kernel.version: "2.3.0-feature-x"`
in its instance. Remove `build_steps.branch` afterwards.

## Build the production image

1. Set the release number in `project/config/build.yaml` (`kernel.version`, e.g. `1.4.0`) and commit it.
2. Check the build config: `./mercy config --stage=build`.
3. Build in your dev folder (takes several minutes):

```bash
./mercy build                # --info lists the steps, ./mercy build <step> continues
```

By default the image is built from **releases**: the latest tag of the scaffold, the versions in `base_requires` and
`requires`, the libraries of `composer.lock`. Your `local.yaml` is ignored. Tag your repositories before a release build.

The build works in `storage/docker-builds/prod-build`: it clones the scaffold, applies the build stage, installs
dependencies without dev packages, builds the frontend, writes `build.lock.yaml`, removes build-only files, builds and
saves the image and, depending on `build_steps`, creates an offline bundle and pushes to the registry (`<git.registry_source>/<git.registry_namespace>/<image>:<version>`). The registry login is asked
for once, before
anything is built.

Business imports and secrets are never part of the image.

## Production

Install the image on a server with the [Mercy-Installer](https://github.com/aklebe-laravel/mercy-installer). It has the
same layout as the scaffold (`project/`, `resources/setup/`, `storage/app/last-setup/`), uses the same project
repository with the stage `prod`, and takes `compose.yaml` and the templates out of the image, so they always match the
release.

```bash
git clone https://github.com/aklebe-laravel/mercy-installer.git . && git clone <your-project-repository> project
composer install && ./mercy install --instance=<name>
```

New release: change `kernel.version` of the instance (or `prod.yaml`), `git -C project pull`, `./mercy update`.

## Using your own git server

All code and `composer.json` files use the GitHub URLs of `aklebe-laravel`. To fetch from your own server instead (e.g. a Gitea that mirrors to GitHub), add rewrites to the config of your network:

```yaml
# project/config/networks/home.yaml
git:
  url_rewrites:
    - base: "gitea@git.example.com:aklebe-laravel/"
      instead_of: [ "https://github.com/aklebe-laravel/", "git@github.com:aklebe-laravel/" ]
ssh:
  known_hosts: [ github.com, git.example.com ]
  fingerprints:
    git.example.com: 'SHA256:...'   # on the server: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

`install`, `update` and `build` (step `setup_host`) then set the `insteadOf` rewrites in the global git config of the
machine and inside the containers, add the server to `~/.ssh/known_hosts` (only with a matching fingerprint) and test
the access. When the base changes, the old rewrite is removed automatically. Without `url_rewrites` everything comes
from GitHub.

One key per machine: the deploy key `ssh.key` is used by the containers and by every git and composer call of the
deployment (`GIT_SSH_COMMAND`). Your own git commands keep using your personal key.

## Versions and releases

A version belongs to an image, not to an environment:

| Stage      | Version                                                                        |
|------------|--------------------------------------------------------------------------------|
| dev        | no fixed number: `git describe` of the project, e.g. `v1.4.0-3-g1a2b3c4-dirty` |
| build      | `kernel.version` in `build.yaml`: image tag, `APP_VERSION`, image labels       |
| production | `kernel.version` in `prod.yaml` or the instance: the release to run            |

`sail artisan mercy:info` shows what really runs. Keep `kernel.version` out of `setup.yaml` and `dev.yaml`, otherwise it
overrides the git version in dev.

Mercy itself is released per repository (each has its own version). Releases of the Mercy repositories are tagged on the
internal Gitea and mirrored to GitHub with the `mercy-migrate` tool of the Mercy team.

## Development reference

| Task                                        | Command                                                                                  |
|---------------------------------------------|------------------------------------------------------------------------------------------|
| start / stop containers                     | `sail up -d` / `sail down`                                                               |
| rebuild containers                          | `sail build --no-cache`                                                                  |
| Vite dev server                             | `sail npm run dev`                                                                       |
| shell in the app container                  | `sail shell`                                                                             |
| URLs, ports and important env values        | `sail artisan mercy:info`                                                                |
| composer, npm, clear caches, build frontend | `sail artisan mercy:app update`                                                          |
| clear caches and views                      | `sail artisan mercy:app cache,view`                                                      |
| build frontend                              | `sail artisan mercy:app build-frontend`                                                  |
| clone / update modules and themes           | `sail artisan mercy:app require`                                                         |
| migrations and all deployments              | `sail artisan mercy:app migrate`                                                         |
| everything after bigger changes             | `sail artisan mercy:app migrate,build-frontend,cache,view`                               |
| run new deployments of modules and imports  | `sail artisan deploy-env:terraform-modules`                                              |
| run business imports again                  | `sail artisan deploy-env:terraform-modules --module_name=local:business-imports --force` |
| modules ordered by priority                 | `sail artisan deploy-env:module-info`                                                    |
| IDE helper files                            | `sail artisan mercy:app ide`                                                             |

All `mercy:app` services and `deploy-env:*` commands: [DeployEnv README](https://github.com/aklebe-laravel/deploy-env-module#console).

**New module** from the stubs of DeployEnv:

```bash
sail artisan deploy-env:make-module MyModule
```

**Model, form and data table classes** (with the Form and DataTable modules):

```bash
sail artisan deploy-env:former MyModule --classes=country,some-thing
```

This creates `app/Models/Country.php`, `app/Forms/Country.php`, `app/Http/Livewire/Form/Country.php` and
`app/Http/Livewire/DataTable/Country.php` in the module (existing files are not changed). Without `--classes`, all
models of the module are used. Other modules can add files by listening to the event `DeployEnvFormer`.

`sail` alias:

```bash
echo "alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'" >> ~/.bashrc
```

## Folder structure

| Path                      | Meaning                                                                               |
|---------------------------|---------------------------------------------------------------------------------------|
| `mercy`                   | the CLI                                                                               |
| `project/`                | **your project repository**, the only place to edit configs                           |
| `Modules/`, `themes/`     | cloned modules and themes (own git repositories, not part of the scaffold)            |
| `resources/setup/`        | scaffold templates: new project, `setup-*.env`, `.env.minimal`, `core.yaml`, nginx    |
| `resources/production/`   | `compose.yaml` of production (copied out of the image by the installer)               |
| `storage/app/last-setup/` | generated: merged configs and envs of this machine (fixed keys and ports), never edit |
| `install/project-root/`   | files copied to the project root during install and build                             |
| `docker/`                 | Dockerfile, nginx and PHP config, `start-container`                                   |
| `storage/docker-builds/`  | build folder of the production image                                                  |

## Maintenance

**Remove an installation:**

```bash
./mercy destroy                    # containers, networks, volumes (the DATABASE), proxy hosts, images built here
./mercy destroy --images --files   # also pulled images and all files of the folder
```

`destroy` reads the project name from Docker, asks you to type it and, with `--files`, refuses while a repository in the
folder (scaffold, `project/`, modules, themes) has uncommitted or unpushed changes. `--force` skips both checks.

**Recommended `/etc/docker/daemon.json`** (log rotation, build cache limit):

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

## Troubleshooting

| Situation                                  | What to do                                                                                   |
|--------------------------------------------|----------------------------------------------------------------------------------------------|
| not sure what state the installation is in | `./mercy`                                                                                    |
| a step failed                              | fix the cause, then `./mercy <command> <step>`; config-preparing steps always run again      |
| a setting seems to be ignored              | `./mercy config <key>` shows the value and its origin; check the warnings about unknown keys |
| the install waits for a deploy key         | add the shown public key at your git server; the install tests again                         |
| "an instance is required"                  | `./mercy <command> --instance=<tab>`                                                         |
| ports collide with another project         | set another `provisioning.auto_port_start` in the instance, then `./mercy update`            |
| `composer.lock` warning in `./mercy`       | the lock points to a local library: remove it from `local.yaml`, `./mercy update`, commit    |

## License

MIT, see [LICENSE.md](LICENSE.md).
