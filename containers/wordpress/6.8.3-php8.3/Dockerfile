ARG ALPINE_VERSION=3.22
ARG PHP_VERSION=8.3
ARG PHP_FULL_VERSION=8.3.26
ARG PHP_RELEASE=r0

FROM alpine:${ALPINE_VERSION}

# Metadata labels
LABEL org.opencontainers.image.title="WordPress"
LABEL org.opencontainers.image.description="WordPress 6.8.3 with PHP ${PHP_VERSION} and Apache on Alpine Linux"
LABEL org.opencontainers.image.version="6.8.3-php${PHP_VERSION}"
LABEL org.opencontainers.image.authors="Displace Technologies <hello@displace.tech>"
LABEL org.opencontainers.image.url="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.documentation="https://github.com/displacetech/containers/tree/main/containers/wordpress"
LABEL org.opencontainers.image.source="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.vendor="Displace Technologies"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.base.name="alpine:${ALPINE_VERSION}"

# WordPress and WP-CLI versions
ENV WORDPRESS_VERSION=6.8.3
ENV WORDPRESS_SHA256=92da34c9960e64d1258652c1ef73c517f7e46ac6dfd2dfc75436d3855af46b0c
ENV WPCLI_VERSION=2.12.0

# Install Apache, PHP, and WordPress dependencies
RUN apk add --no-cache \
    apache2=2.4.65-r0 \
    apache2-ssl=2.4.65-r0 \
    apache2-utils=2.4.65-r0 \
    php83=8.3.26-r0 \
    php83-apache2=8.3.26-r0 \
    php83-mysqli=8.3.26-r0 \
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
    php83-fileinfo=8.3.26-r0 \
    php83-session=8.3.26-r0 \
    php83-iconv=8.3.26-r0 \
    php83-ctype=8.3.26-r0 \
    php83-tokenizer=8.3.26-r0 \
    php83-opcache=8.3.26-r0 \
    php83-exif=8.3.26-r0 \
    php83-pecl-imagick=3.8.0-r1 \
    wget \
    unzip \
    less \
    mysql-client \
    curl \
    && ln -sf /usr/bin/php83 /usr/bin/php \
    && rm -rf /var/cache/apk/*

# Use existing system users (apache from Apache package, www-data from PHP package)
# apache: UID=100, GID=101
# www-data: GID=82 (group exists, add user)
RUN adduser -D -u 1001 -G www-data -s /bin/sh www-data

# Create directories and set permissions
RUN mkdir -p /var/www/html \
             /var/log/apache2 \
             /run/apache2 \
    && chown -R apache:apache /var/log/apache2 /run/apache2 \
    && chown -R www-data:www-data /var/www/html

# Download and verify WordPress
RUN wget -O wordpress.tar.gz "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" \
    && echo "$WORDPRESS_SHA256  wordpress.tar.gz" | sha256sum -c - \
    && tar -xzf wordpress.tar.gz -C /var/www/html --strip-components=1 \
    && rm wordpress.tar.gz \
    && chown -R www-data:www-data /var/www/html

# Download and install WP-CLI
RUN wget -O /usr/local/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar \
    && chmod +x /usr/local/bin/wp

# Copy configuration files
COPY httpd.conf /etc/apache2/httpd.conf
COPY php.ini /etc/php${PHP_VERSION/./}/php.ini
COPY wp-config-docker.php /usr/local/src/wp-config-docker.php
COPY wp-cli.yml /var/www/html/wp-cli.yml
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Set permissions for copied files
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && chown www-data:www-data /usr/local/src/wp-config-docker.php \
    && chown www-data:www-data /var/www/html/wp-cli.yml

# Create WordPress directories
RUN mkdir -p /var/www/html/wp-content/uploads \
             /var/www/html/wp-content/cache \
             /var/www/html/wp-content/upgrade \
    && chown -R www-data:www-data /var/www/html/wp-content \
    && chmod 755 /var/www/html/wp-content/uploads

# Environment variables for WordPress configuration
ENV WORDPRESS_DB_HOST=""
ENV WORDPRESS_DB_NAME=""
ENV WORDPRESS_DB_USER=""
ENV WORDPRESS_DB_PASSWORD=""
ENV WORDPRESS_TABLE_PREFIX="wp_"
ENV WORDPRESS_AUTH_KEY=""
ENV WORDPRESS_SECURE_AUTH_KEY=""
ENV WORDPRESS_LOGGED_IN_KEY=""
ENV WORDPRESS_NONCE_KEY=""
ENV WORDPRESS_AUTH_SALT=""
ENV WORDPRESS_SECURE_AUTH_SALT=""
ENV WORDPRESS_LOGGED_IN_SALT=""
ENV WORDPRESS_NONCE_SALT=""
ENV WORDPRESS_DEBUG="false"
ENV WORDPRESS_DEBUG_LOG="false"

# Expose port 8080 for WordPress
EXPOSE 8080

# Health check for WordPress
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# WordPress data volume
VOLUME ["/var/www/html"]

# Entry point
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["httpd", "-D", "FOREGROUND"]
