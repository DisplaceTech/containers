FROM alpine:3.22

# Metadata labels
LABEL org.opencontainers.image.title="Apache HTTP Server"
LABEL org.opencontainers.image.description="Apache HTTP Server 2.4.65 on Alpine Linux"
LABEL org.opencontainers.image.version="2.4.65"
LABEL org.opencontainers.image.authors="Displace Technologies <hello@displace.tech>"
LABEL org.opencontainers.image.url="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.documentation="https://github.com/displacetech/containers/tree/main/containers/apache"
LABEL org.opencontainers.image.source="https://github.com/displacetech/containers"
LABEL org.opencontainers.image.vendor="Displace Technologies"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.base.name="alpine:3.22"

# Install Apache and common modules
RUN apk add --no-cache \
    apache2=2.4.65-r0 \
    apache2-ssl=2.4.65-r0 \
    apache2-utils=2.4.65-r0 \
    curl \
    && rm -rf /var/cache/apk/*

# Use the existing apache user (created by package installation)
# UID: 100, GID: 101

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html \
             /var/log/apache2 \
             /run/apache2 \
    && chown -R apache:apache /var/www/html \
                              /var/log/apache2 \
                              /run/apache2 \
    && chmod -R 755 /var/www/html

# Configure Apache
COPY httpd.conf /etc/apache2/httpd.conf
COPY ssl.conf /etc/apache2/conf.d/ssl.conf

# Create default index.html
RUN echo '<!DOCTYPE html>\n\
<html>\n\
<head>\n\
    <title>Apache HTTP Server - Displace Technologies</title>\n\
    <style>\n\
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }\n\
        .container { background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }\n\
        h1 { color: #333; }\n\
        .version { color: #666; font-size: 14px; }\n\
    </style>\n\
</head>\n\
<body>\n\
    <div class="container">\n\
        <h1>🚀 Apache HTTP Server</h1>\n\
        <p>Your Apache server is running successfully!</p>\n\
        <div class="version">Apache 2.4.65 • Alpine Linux 3.22 • Displace Technologies</div>\n\
    </div>\n\
</body>\n\
</html>' > /var/www/html/index.html \
    && chown apache:apache /var/www/html/index.html

# Switch to non-root user
USER apache

# Expose ports
EXPOSE 80 443

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start Apache in foreground
CMD ["httpd", "-D", "FOREGROUND"]