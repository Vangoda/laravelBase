# Start from PHP 7.4 Image
FROM php:7.4-alpine

# Add mlocatis php extension installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Set workdir
WORKDIR "/var/www/html"

# Copy default apache configuration
# COPY apache2 conf
COPY ./apache/apache2.conf /etc/apache2/apache2.conf
COPY ./apache/default/ /etc/apache2/sites-available

# Make it executable
RUN chmod +x /usr/local/bin/install-php-extensions\
# PHP  extensions and composer using mlocati/docker-php-extension-installer
  && install-php-extensions opcache xdebug pdo_mysql @composer\
# Install laravel
  && composer create-project --prefer-dist laravel/laravel .\
  # Set laravel permissions
  && chown www-data:www-data . -R\
  && chmod 775 . -R\
# Install git, nodejs, postfix, curl and npm
  && apk update\
  && apk add git nodejs npm postfix curl\
  && npm install gulp -g\
  && npm install @vue/cli -g\
  && npm install gulp --save-dev\
#   Configure xdebug
  && { \
    echo "xdebug.mode=debug,profile,trace"; \
    echo "xdebug.client_host=127.0.0.1"; \
    echo "xdebug.client_port=9003"; \
  } > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Start the laravel server
CMD php artisan serve --host=0.0.0.0 --port=80
