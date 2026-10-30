# My Project

Project repository for a [Mercy Scaffold](https://github.com/aklebe-laravel/mercy-scaffold) application:
everything that makes this project different from the scaffold. Created by `./mercy project:init`.

| Path                  | Meaning                                                         |
|-----------------------|-----------------------------------------------------------------|
| `config/setup.yaml`   | the product (name, image, theme, modules, ...)                  |
| `config/networks/`    | settings of a network/site (own git server, NPM, LDAP, DNS)     |
| `config/dev.yaml`     | differences of the dev environment                              |
| `config/build.yaml`   | differences of the production image (release number)            |
| `config/prod.yaml`    | differences of the production server (release to run)           |
| `config/secrets.yaml` | passwords and keys of this machine, **not versioned**           |
| `business_imports/`   | data imports (their secrets: env vars in `config/secrets.yaml`) |

Merge order: Mercy defaults → `setup.yaml` → (`networks/*.yaml`) → `<stage>.yaml` → `secrets.yaml` → `<stage>.secrets.yaml`.
The files contain only what differs from the Mercy defaults (they come with mercy-php-deployment), so a new
Mercy version brings new settings without changing them. Unknown keys (typos, old names) are reported.
Maps are merged key by key, lists (like `requires`) are replaced as a whole.
A stage file can inherit more files, e.g. settings of your network: `extends: [ setup.yaml, networks/home.yaml ]`.
The domain belongs to the instance, so it is set in the stage files.

Secrets: `config/secrets.yaml` exists only on the machine (not versioned). Values that may be versioned (e.g. the
password of a local dev tool) go into a file ending with `-secrets.yaml`, e.g. `config/shared-secrets.yaml`, inherited
where they belong (`extends: [ ../shared-secrets.yaml ]`): masked in `config`, but versioned. Not for production secrets.

Show the effective config and where each value comes from (`--all` also the Mercy defaults,
`--redundant` the values here that equal a default and can be removed):

```
./mercy config [filter] [--stage=dev|build|prod] [--all] [--redundant]
```

## Instances

One installation (a folder on a machine) is one instance: a few lines in `config/instances/<name>.yaml`,
everything else is inherited. The structure is changed in one place (`setup.yaml`, `networks/`), never per instance.

```yaml
# config/instances/vm-dev.yaml
extends: [ ../networks/example.yaml ]   # the network of this machine
kernel:
  domain: "my-product.dev.example.com"
  ip: "192.0.2.75"
provisioning:
  auto_port_start: 27500                # several instances on one machine: other ports
```

Choose it once per installation, it is remembered in `project/.instance` (not versioned):

```
./mercy install --instance=vm-dev
./mercy update                    # uses vm-dev
./mercy config --instance=vm-prod # only a look at another instance
```

Order: Mercy defaults → `setup.yaml` → `<stage>.yaml` → the instance (with its network) → `secrets.yaml`.
As soon as `config/instances/` has files, every command needs an instance (no run with the wrong config).

## Branches and libraries of this machine

What is checked out stays (your IDE switches branches). `config/local.yaml` (not versioned, merged last) only says
what new clones and libraries take, e.g.:

```yaml
git:
  branch: master                                      # new clones of modules/themes: unreleased master
  branches: { acl-module: feature-y }                 # single repos, also libraries (must exist)
  library_paths: { mercy-php-deployment: ../MercyPhpDeployment }   # your own working copy of a library
```

Then `./mercy update`; `./mercy` shows what is active. Do not commit `composer.lock` while a library comes from a
branch or folder. More examples: scaffold README "Workflows".

## Dev

Clone this repository as `project/` into the scaffold folder, create `config/secrets.yaml`, then `./mercy install`.

## Production

Clone it as `project/` into the Mercy-Installer folder, create `config/secrets.yaml`, then `./mercy install`.
Later: `git -C project pull && ./mercy update`.

Keep a copy of the secret files in your password manager, they exist only on the machines.
