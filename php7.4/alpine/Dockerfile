ARG PHP_VERSION=7.4

FROM php:${PHP_VERSION}-fpm-alpine AS base

RUN apk --no-cache add git supervisor vim zip unzip \
	libzip freetype libjpeg-turbo libpng libwebp postgresql \
	libzip-dev freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev postgresql-dev && \
	docker-php-ext-configure zip && \
	docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
	docker-php-ext-install exif gd opcache mysqli pdo_pgsql pdo_mysql zip && \
	apk --no-cache del libzip-dev freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev postgresql-dev

# Install composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

FROM base as builder

USER www-data

# Install Winter CMS
RUN composer create-project wintercms/winter . --no-interaction --no-cache "dev-develop" && \
	composer clearcache && \
	echo 'APP_ENV=docker' > .env && \
	touch storage/database.sqlite && \
	chmod 666 storage/database.sqlite

FROM base

COPY --from=builder /var/www/html /var/www/html
COPY config/wintercms /var/www/html/config/docker

COPY config/supervisord.conf /etc/supervisord.conf
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint


# Sets recommended PHP.ini settings (https://secure.php.net/manual/en/opcache.installation.php)
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/docker-wn-opcache.ini

RUN { \
		echo 'log_errors=on'; \
		echo 'display_errors=off'; \
		echo 'upload_max_filesize=128M'; \
		echo 'post_max_size=128M'; \
		echo 'memory_limit=256M'; \
		echo 'expose_php=off'; \
	} > /usr/local/etc/php/conf.d/docker-wn-php.ini

# Cron
RUN echo "* * * * * /usr/bin/php /var/www/artisan schedule:run >> /dev/null 2>&1\n" > /var/spool/cron/crontabs/www-data

# Helpers (based on https://github.com/aspendigital/docker-octobercms)
RUN echo 'exec php artisan "$@"' > /usr/local/bin/artisan && \
	echo 'exec php artisan tinker' > /usr/local/bin/tinker && \
	echo '[ $# -eq 0 ] && exec php artisan winter || exec php artisan winter:"$@"' > /usr/local/bin/winter && \
	sed -i '1s;^;#!/bin/sh\n[ "$PWD" != "/var/www/html" ] \&\& echo "must be run from /var/www/html" \&\& exit 1\n;' /usr/local/bin/artisan /usr/local/bin/tinker /usr/local/bin/winter && \
	chmod +x /usr/local/bin/docker-entrypoint /usr/local/bin/artisan /usr/local/bin/tinker /usr/local/bin/winter

VOLUME ["/var/www/html/storage"]

ENV APP_ENV="docker"

ENTRYPOINT ["docker-entrypoint"]

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
