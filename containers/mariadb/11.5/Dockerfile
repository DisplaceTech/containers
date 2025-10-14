FROM alpine:3.22

# Metadata labels
LABEL org.opencontainers.image.title="MariaDB Server"
LABEL org.opencontainers.image.description="MariaDB Server on Alpine Linux optimized for WordPress"
LABEL org.opencontainers.image.version="11.5"
LABEL org.opencontainers.image.authors="Displace Technologies <hello@displace.tech>"
LABEL org.opencontainers.image.url="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.documentation="https://github.com/displacetech/containers/tree/main/containers/mariadb"
LABEL org.opencontainers.image.source="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.vendor="Displace Technologies"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.base.name="alpine:3.22"

# Install MariaDB and required packages
RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-server-utils \
    pwgen \
    tzdata \
    && rm -rf /var/cache/apk/*

# Use the existing mysql user and group (created by MariaDB package)
# UID: 100, GID: 101

# Create required directories and set permissions
RUN mkdir -p /var/lib/mysql \
             /var/log/mysql \
             /run/mysqld \
             /docker-entrypoint-initdb.d \
    && chown -R mysql:mysql /var/lib/mysql \
                            /var/log/mysql \
                            /run/mysqld \
    && chmod 755 /docker-entrypoint-initdb.d

# Copy configuration files
COPY my.cnf /etc/my.cnf.d/custom.cnf
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Ensure mysql user owns the directories (database will be initialized at runtime)
RUN chown -R mysql:mysql /var/lib/mysql /var/log/mysql /run/mysqld

# Environment variables with defaults
ENV MYSQL_ROOT_PASSWORD=""
ENV MYSQL_DATABASE=""
ENV MYSQL_USER=""
ENV MYSQL_PASSWORD=""
ENV MYSQL_ALLOW_EMPTY_PASSWORD="no"
ENV MYSQL_RANDOM_ROOT_PASSWORD="no"

# Expose MySQL port
EXPOSE 3306

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD mariadb-admin ping -h localhost || exit 1

# Data volume
VOLUME ["/var/lib/mysql"]

# Switch back to mysql user for runtime
USER mysql

# Entry point
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mariadbd", "--user=mysql"]