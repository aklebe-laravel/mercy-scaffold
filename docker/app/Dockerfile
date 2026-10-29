# =====================================================================
# Two stages, kept simple:
#
#   base        PHP + nginx + supervisor + Composer + Node + Git/SSH.
#
#   production  Packs the FINISHED build folder into the image. The folder is
#               assembled beforehand by "./mercy build" (vendor, modules, frontend build).
#               There is no SSH, no .env and no module sync in this Dockerfile.
#               Everything that must not end up in the image (.env, .git,
#               node_modules, storage/app, ...) belongs into the .dockerignore.
# =====================================================================

# --- STAGE 0: NODE ASSET PROVIDER ---
# Use the official Node image only as a source for the node/npm binaries
FROM node:22-slim AS node-source

# --- STAGE 1: BASE ---
FROM ubuntu:24.04 AS base

# The only place to change the PHP version of the image (also update BaseCommand::$requiredPhp of the deployment).
ARG PHP_VERSION=8.5

ARG WWWGROUP=1000
ARG WWWUSER=1000

WORKDIR /var/www/html
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# 1. Set timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 2. Use a fast mirror and enable the universe repository
RUN sed -i 's|Components: main restricted|Components: main restricted universe multiverse|g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's|http://archive.ubuntu.com/ubuntu/|http://mirror.netcologne.de/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's|http://security.ubuntu.com/ubuntu/|http://mirror.netcologne.de/ubuntu/|g' /etc/apt/sources.list.d/ubuntu.sources

# 3. Aggressive timeouts and no retries: fail fast instead of waiting endlessly
RUN echo 'Acquire::Retries "0"; Acquire::http::Timeout "30"; Acquire::https::Timeout "30"; APT::Keep-Downloaded-Packages "false";' > /etc/apt/apt.conf.d/99custom-timeouts

# 4. Install essential base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg gosu curl ca-certificates \
    && mkdir -p /etc/apt/keyrings

# 5. Add the GPG key and the repository for PHP.
#    HTTPS is mandatory here: the key decides which packages apt trusts.
RUN curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/keyrings/ondrej-php.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/ondrej-php.gpg] https://packages.sury.org/php/ noble main" | tee /etc/apt/sources.list.d/ondrej-php.list

# 6. Update APT and install all packages including the openssh-client
RUN apt-get update && apt-get install -y --no-install-recommends \
    zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python3 dnsutils librsvg2-bin fswatch ffmpeg nano software-properties-common \
    openssh-client \
    nginx \
    mariadb-client \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-dev \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-igbinary \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-ldap \
    && apt-get -y autoremove && apt-get clean && rm -rf /var/lib/apt/lists/*

# Version-neutral name of the FPM binary (used by supervisord.conf)
RUN ln -sf /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm

# 7. Copy Composer and Node.js/npm straight from their official images (no installer script download)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY --from=node-source /usr/local/bin/node /usr/bin/node
COPY --from=node-source /usr/local/lib/node_modules /usr/lib/node_modules
RUN ln -s /usr/lib/node_modules/npm/bin/npm-merge-driver.js /usr/bin/npm-merge-driver \
    && ln -s /usr/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm \
    && ln -s /usr/lib/node_modules/npm/bin/npx-cli.js /usr/bin/npx

# Fix user IDs (standardized to 1000)
RUN userdel -r ubuntu || true && \
    if getent group 1000; then groupdel $(getent group 1000 | cut -d: -f1); fi

# Create the sail group and user (UID/GID 1000 by default)
RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u $WWWUSER sail

# Create runtime directories before copying configurations
RUN mkdir -p /var/run/php /var/log/supervisor

# Copy configs
COPY docker/app/start-container /usr/local/bin/start-container
COPY docker/app/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/app/php.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-sail.ini
COPY docker/app/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY docker/app/nginx.conf /etc/nginx/sites-available/default
RUN chmod +x /usr/local/bin/start-container

# Create symlink for supervisorctl, forcing overwrite if the file exists
RUN ln -sf /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/supervisord.conf

# Let nginx run as the sail user
RUN sed -i "s/user www-data;/user sail;/" /etc/nginx/nginx.conf

# Make sure nginx, PHP-FPM and supervisor can write to their paths
RUN chown -R sail:sail /var/lib/nginx /var/log/nginx /var/run/php /var/log/supervisor

ENTRYPOINT ["start-container"]

# --- STAGE 2: PRODUCTION ---
FROM base AS production

# Copy the finished build folder (respecting .dockerignore)
COPY --chown=sail:sail . /var/www/html

# Remove stale runtime leftovers and create the Laravel runtime directories.
# The paths are spelled out on purpose: RUN uses /bin/sh, which has no {a,b} brace expansion.
RUN rm -rf /var/www/html/storage/logs/* /var/www/html/bootstrap/cache/* \
    && mkdir -p \
        /var/www/html/storage/logs \
        /var/www/html/storage/framework/sessions \
        /var/www/html/storage/framework/views \
        /var/www/html/storage/framework/cache/data \
        /var/www/html/storage/app/mercy-generated \
        /var/www/html/storage/app/public \
        /var/www/html/bootstrap/cache \
    && chown -R sail:sail /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Bake the public storage link into the image (same as "php artisan storage:link").
# public/ is part of the image, not of a volume: a link created at runtime is lost
# whenever the container is recreated (e.g. "docker compose up --force-recreate").
# Relative target, so it resolves into the mounted storage volume.
RUN ln -sfn ../storage/app/public /var/www/html/public/storage \
    && chown -h sail:sail /var/www/html/public/storage