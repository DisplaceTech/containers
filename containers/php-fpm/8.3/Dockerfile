ARG PHP_VERSION=8.3.26
FROM alpine:3.22

# Metadata labels
LABEL org.opencontainers.image.title="PHP-FPM"
LABEL org.opencontainers.image.description="PHP-FPM ${PHP_VERSION:-8.3.26} on Alpine Linux with extensions for WordPress"
LABEL org.opencontainers.image.version="${PHP_VERSION:-8.3.26}"
LABEL org.opencontainers.image.authors="Displace Technologies <hello@displace.tech>"
LABEL org.opencontainers.image.url="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.documentation="https://github.com/displacetech/containers/tree/main/containers/php-fpm"
LABEL org.opencontainers.image.source="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.vendor="Displace Technologies"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.base.name="alpine:3.22"

ARG PHP_VERSION=8.3.26

# Install PHP and essential extensions for WordPress
RUN apk add --no-cache \
    php83=8.3.26-r0 \
    php83-fpm=8.3.26-r0 \
    php83-opcache=8.3.26-r0 \
    php83-mysqli=8.3.26-r0 \
    php83-pdo=8.3.26-r0 \
    php83-pdo_mysql=8.3.26-r0 \
    php83-openssl=8.3.26-r0 \
    php83-curl=8.3.26-r0 \
    php83-xml=8.3.26-r0 \
    php83-xmlwriter=8.3.26-r0 \
    php83-xmlreader=8.3.26-r0 \
    php83-simplexml=8.3.26-r0 \
    php83-dom=8.3.26-r0 \
    php83-mbstring=8.3.26-r0 \
    php83-gd=8.3.26-r0 \
    php83-intl=8.3.26-r0 \
    php83-zip=8.3.26-r0 \
    php83-exif=8.3.26-r0 \
    php83-fileinfo=8.3.26-r0 \
    php83-tokenizer=8.3.26-r0 \
    php83-session=8.3.26-r0 \
    php83-iconv=8.3.26-r0 \
    php83-bcmath=8.3.26-r0 \
    php83-ctype=8.3.26-r0 \
    php83-posix=8.3.26-r0 \
    php83-sodium=8.3.26-r0 \
    php83-pecl-redis=6.2.0-r0 \
    php83-pecl-imagick=3.8.0-r1 \
    curl \
    && rm -rf /var/cache/apk/*

# Create symlinks for compatibility
RUN ln -sf /usr/bin/php83 /usr/bin/php \
    && ln -sf /usr/sbin/php-fpm83 /usr/sbin/php-fpm

# Create non-root user (www-data group already exists from PHP packages)
RUN adduser -D -u 1001 -G www-data -s /bin/sh www-data

# Create required directories
RUN mkdir -p /var/log/php-fpm \
             /var/run/php-fpm \
             /var/www/html \
    && chown -R www-data:www-data /var/log/php-fpm \
                                  /var/run/php-fpm \
                                  /var/www/html

# Copy configuration files
COPY php.ini /etc/php83/php.ini
COPY php-fpm.conf /etc/php83/php-fpm.conf
COPY www.conf /etc/php83/php-fpm.d/www.conf

# Create a simple PHP info page for testing
RUN echo '<?php\n\
echo "<h1>🐘 PHP-FPM " . PHP_VERSION . "</h1>";\n\
echo "<p>Running on Alpine Linux</p>";\n\
echo "<p>Built by Displace Technologies</p>";\n\
echo "<hr>";\n\
phpinfo();\n\
?>' > /var/www/html/index.php \
    && chown www-data:www-data /var/www/html/index.php

# Switch to non-root user
USER www-data

# Expose PHP-FPM port
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD php-fpm -t || exit 1

# Start PHP-FPM
CMD ["php-fpm", "-F"]