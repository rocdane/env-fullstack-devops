FROM php:8.2-fpm

RUN apt-get update && apt-get install -y libpq-dev zip unzip git curl && docker-php-ext-install pdo pdo_pgsql zip

WORKDIR /var/www/html

COPY . .

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]