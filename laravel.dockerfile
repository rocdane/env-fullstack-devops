# Étape 1 : image officielle PHP avec extensions nécessaires
FROM php:8.2-fpm

# Installer les dépendances système, extensions PHP requises, et Composer
RUN apt-get update && apt-get install -y git unzip libpq-dev libzip-dev zip curl docker-php-ext-install pdo pdo_pgsql zip && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copier le code source Laravel
WORKDIR /var/www/html
COPY . .

# Installer les dépendances PHP avec Composer
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Permissions (selon ton besoin)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Exposer le port PHP-FPM (par défaut 9000)
EXPOSE 9000

CMD ["php-fpm"]
