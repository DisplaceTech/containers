ARG PHP_VERSION=8.4.13
FROM alpine:3.22

# Metadata labels
LABEL org.opencontainers.image.title="PHP-FPM"
LABEL org.opencontainers.image.description="PHP-FPM ${PHP_VERSION:-8.4.13} on Alpine Linux with extensions for WordPress"
LABEL org.opencontainers.image.version="${PHP_VERSION:-8.4.13}"
LABEL org.opencontainers.image.authors="Displace Technologies <hello@displace.tech>"
LABEL org.opencontainers.image.url="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.documentation="https://github.com/displacetech/containers/tree/main/containers/php-fpm"
LABEL org.opencontainers.image.source="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.vendor="Displace Technologies"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.base.name="alpine:3.22"

ARG PHP_VERSION=8.4.13

# Install PHP and essential extensions for WordPress
RUN apk add --no-cache \
    php84=8.4.13-r0 \
    php84-fpm=8.4.13-r0 \
    php84-opcache=8.4.13-r0 \
    php84-mysqli=8.4.13-r0 \
    php84-pdo=8.4.13-r0 \
    php84-pdo_mysql=8.4.13-r0 \
    php84-json=8.4.13-r0 \
    php84-openssl=8.4.13-r0 \
    php84-curl=8.4.13-r0 \
    php84-zlib=8.4.13-r0 \
    php84-xml=8.4.13-r0 \
    php84-xmlwriter=8.4.13-r0 \
    php84-xmlreader=8.4.13-r0 \
    php84-simplexml=8.4.13-r0 \
    php84-dom=8.4.13-r0 \
    php84-mbstring=8.4.13-r0 \
    php84-gd=8.4.13-r0 \
    php84-intl=8.4.13-r0 \
    php84-zip=8.4.13-r0 \
    php84-exif=8.4.13-r0 \
    php84-fileinfo=8.4.13-r0 \
    php84-tokenizer=8.4.13-r0 \
    php84-session=8.4.13-r0 \
    php84-iconv=8.4.13-r0 \
    php84-bcmath=8.4.13-r0 \
    php84-ctype=8.4.13-r0 \
    php84-filter=8.4.13-r0 \
    php84-hash=8.4.13-r0 \
    php84-pcre=8.4.13-r0 \
    php84-posix=8.4.13-r0 \
    php84-sodium=8.4.13-r0 \
    php84-redis=8.4.13-r0 \
    php84-pecl-imagick=8.4.13-r0 \
    curl \
    && rm -rf /var/cache/apk/*

# Create symlinks for compatibility
RUN ln -sf /usr/bin/php84 /usr/bin/php \
    && ln -sf /usr/sbin/php-fpm84 /usr/sbin/php-fpm

# Create non-root user
RUN addgroup -g 1001 www-data && \
    adduser -D -u 1001 -G www-data -s /bin/sh www-data

# Create required directories
RUN mkdir -p /var/log/php-fpm \
             /var/run/php-fpm \
             /var/www/html \
    && chown -R www-data:www-data /var/log/php-fpm \
                                  /var/run/php-fpm \
                                  /var/www/html

# Copy configuration files
COPY php.ini /etc/php84/php.ini
COPY php-fpm.conf /etc/php84/php-fpm.conf
COPY www.conf /etc/php84/php-fpm.d/www.conf

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