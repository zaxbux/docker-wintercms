#!/usr/bin/env sh
set -e

php artisan winter:up

exec docker-php-entrypoint "$@"