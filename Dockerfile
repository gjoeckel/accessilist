# Production Mirror - Matches AWS Production Server
# Apache 2.4.52, PHP 8.1, mod_rewrite enabled

FROM php:8.1-apache

# Enable Apache modules (matches production)
RUN a2enmod rewrite headers

# Set ServerName to suppress warnings
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configure Apache for .htaccess support (AllowOverride All)
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
