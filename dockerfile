# Base image
FROM php:8.1-cli

# Install system dependencies
RUN apt-get update --allow-releaseinfo-change && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    git \
    curl \
    unzip

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy Laravel project files to container
COPY . .

# Install PHP dependencies
RUN composer install

# Copy existing application .env file
COPY .env.example .env

# Set proper permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

# Generate application key
RUN php artisan key:generate

# Expose port for Laravel's built-in server
EXPOSE 7080

# Set the command to run Laravel's built-in server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=7080"]
