# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Docker image builder** that produces pre-built PHP runtime images published as `nekoimi/rafutaria-php` on Docker Hub. It is **not** a PHP application. The images bundle PHP with common extensions (yaf, redis, xdebug, swoole, etc.) for two runtime modes: **fpm** (PHP-FPM + Nginx via supervisord) and **cli** (standalone PHP CLI, optionally with Swoole).

## Repository Structure

- `7.1/`, `7.2/`, `7.4/`, `8/` — Dockerfiles per PHP version, each with `cli/` and `fpm/` subdirectories
- `nginx/` — Nginx config templates (used in FPM images)
- `supervisor.d/` — Supervisor configs for php-fpm and nginx processes
- `docker-entrypoint.d/` — Entrypoint scripts that run on container start (sorted alphabetically)
- `docker-entrypoint.sh` — Main entrypoint that discovers and executes `docker-entrypoint.d/*.sh`
- `index.php` — Default `phpinfo()` page placed at `/workspace/public/index.php`

## Build Commands

Build a specific image:
```bash
# FPM image
docker build -t nekoimi/rafutaria-php:7.4-fpm-alpine 7.4/fpm/

# CLI image
docker build -t nekoimi/rafutaria-php:7.4-cli-alpine 7.4/cli/

# With Chinese mirror support (Aliyun CDN for Alpine repos)
docker build --build-arg ENABLE_MIRRORS=on -t nekoimi/rafutaria-php:7.4-fpm-alpine 7.4/fpm/
```

Multi-arch build (requires QEMU + Buildx):
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t nekoimi/rafutaria-php:7.4-fpm-alpine --push 7.4/fpm/
```

## Architecture: Two Runtime Modes

### FPM Mode
- CMD: `supervisord -n -c /etc/supervisord.conf`
- Manages php-fpm (priority 5) and nginx (priority 10) via supervisord
- Nginx listens on port 80, FastCGI passes to `127.0.0.1:9000`
- Document root: `/workspace/public`

### CLI Mode
- CMD: `php -a`
- Includes Swoole extension for async HTTP server use cases
- No Nginx or supervisord

## Entrypoint Scripts

Scripts in `docker-entrypoint.d/` run in alphabetical order before the CMD:

1. `00-cron-entrypoint.sh` — If `CRONTAB_ENABLE=true`, loads crontab from `$WORKSPACE/crontab.conf` or `$WORKSPACE/docker/crontab/*.conf`, starts crond
2. `00-nginx-entrypoint.sh` — FPM only. Templates `NGX_WORKER_PROC` into nginx.conf. Allows project-level vhost override via `$WORKSPACE/docker/nginx/default.conf`
3. `00-php-entrypoint.sh` — Configures php.ini, php-fpm pool (www.conf), xdebug (version-aware v2/v3), runs composer install/update if enabled
4. `00-supervisor-entrypoint.sh` — Copies `$WORKSPACE/docker/supervisor/*.ini` into `/etc/supervisor.d/` for custom background processes

## Key Environment Variables

| Variable | Default | Purpose |
|---|---|---|
| `APPLICATION_ENV` | `dev` | `production` triggers `composer install --no-dev` |
| `COMPOSER_INSTALL` | `false` | Auto-runs `composer install` if `composer.lock` exists |
| `COMPOSER_UPDATE` | `false` | Auto-runs `composer update` if `composer.lock` exists |
| `XDEBUG_ENABLE` | `false` | Enables xdebug |
| `MEMORY_LIMIT` | `256M` | PHP memory_limit |
| `UPLOAD_MAX_SIZE` | `50M` | PHP post_max_size and upload_max_filesize |
| `PHP_PM_MODE` | `dynamic` | php-fpm process manager mode |
| `PHP_PM_MAX_CHILDREN` | `5` | Max fpm children |
| `NGX_WORKER_PROC` | `1` | Nginx worker processes (FPM mode) |

## Workspace Convention

Applications are mounted at `/workspace`. The image supports configuration overrides from subdirectories:
- `$WORKSPACE/docker/nginx/default.conf` — Custom Nginx vhost
- `$WORKSPACE/docker/crontab/*.conf` — Crontab files
- `$WORKSPACE/docker/supervisor/*.ini` — Additional supervisor processes

## CI/CD

GitHub Actions (`.github/workflows/docker-image.yml`) builds and pushes on push/PR to `master`. Currently the matrix only includes PHP 7.1 despite Dockerfiles existing for 7.2, 7.4, and 8. Tag format: `nekoimi/rafutaria-php:{version}-{mode}-alpine`.

## PHP Version Differences

- **PHP 8 FPM** diverges from 7.x patterns: installs Nginx via `apk add` instead of building from source, and installs PECL extensions individually rather than via a loop
- **Composer 2.2.23** is installed in all versions (multi-stage copy in 7.1, direct install in others)
- **mcrypt** is only available in 7.1/7.2/7.4; **imagick** is only in PHP 8
- Default timezone is `Asia/Shanghai`
