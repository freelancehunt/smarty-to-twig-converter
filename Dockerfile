FROM php:8.2.17-cli

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    # Composer needs unzip and git
    && apt-get -y --no-install-recommends install unzip git \
    # Converter needs PDO extension
    && docker-php-ext-install pdo \
    # install Composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && apt-get clean

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

WORKDIR /app
