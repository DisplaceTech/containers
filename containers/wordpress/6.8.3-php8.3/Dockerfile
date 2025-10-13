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
ENV WORDPRESS_SHA256=26b55ab0b1bb0b8ad5a1b21a70b45b4a2e17b7b6a2b98e1c8eaa3ff7e6b3a1a7
ENV WPCLI_VERSION=2.12.0

# Install Apache, PHP, and WordPress dependencies
RUN apk add --no-cache \
    apache2=2.4.65-r0 \
    apache2-ssl=2.4.65-r0 \
    apache2-utils=2.4.65-r0 \
    apache2-mod-rewrite=2.4.65-r0 \
    apache2-mod-headers=2.4.65-r0 \
    php83=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-apache2=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-mysqli=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-pdo_mysql=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-json=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-openssl=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-curl=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-xml=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-xmlwriter=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-xmlreader=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-simplexml=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-dom=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-mbstring=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-gd=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-intl=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-zip=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-fileinfo=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-session=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-iconv=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-ctype=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-filter=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-hash=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-tokenizer=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-opcache=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-exif=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    php83-pecl-imagick=${PHP_FULL_VERSION}-${PHP_RELEASE} \
    wget \
    unzip \
    less \
    mysql-client \
    curl \
    && ln -sf /usr/bin/php83 /usr/bin/php \
    && rm -rf /var/cache/apk/*

# Create users and groups
RUN addgroup -g 1001 apache && \
    adduser -D -u 1001 -G apache -s /bin/sh apache \
    && addgroup -g 1002 www-data \
    && adduser -D -u 1002 -G www-data -s /bin/sh www-data

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
