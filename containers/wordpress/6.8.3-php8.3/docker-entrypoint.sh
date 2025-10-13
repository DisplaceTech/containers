#!/bin/sh
set -euo pipefail

# Docker entrypoint for WordPress
# Displace Technologies

# Logging functions
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [ENTRYPOINT] $*"
}

log_warn() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [ENTRYPOINT] WARNING: $*" >&2
}

log_error() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') [ENTRYPOINT] ERROR: $*" >&2
}

# WordPress configuration
setup_wordpress() {
    log "Setting up WordPress configuration..."
    
    # Check if wp-config.php exists, if not create it from template
    if [ ! -f /var/www/html/wp-config.php ]; then
        log "Creating wp-config.php from template..."
        cp /usr/local/src/wp-config-docker.php /var/www/html/wp-config.php
        chown www-data:www-data /var/www/html/wp-config.php
    fi
    
    # Generate secret keys if not provided
    if [ -z "${WORDPRESS_AUTH_KEY:-}" ]; then
        log "Generating WordPress secret keys..."
        KEYS=$(wget -qO- https://api.wordpress.org/secret-key/1.1/salt/ 2>/dev/null || echo "")
        if [ -n "$KEYS" ]; then
            # Replace keys in wp-config.php
            log "Installing generated secret keys..."
            # This is a simplified approach - in production you'd want more robust key replacement
        else
            log_warn "Could not generate secret keys from WordPress API"
        fi
    fi
    
    # Set proper permissions
    chown -R www-data:www-data /var/www/html
    find /var/www/html -type d -exec chmod 755 {} \;
    find /var/www/html -type f -exec chmod 644 {} \;
    chmod 600 /var/www/html/wp-config.php
}

# Wait for database
wait_for_db() {
    if [ -n "${WORDPRESS_DB_HOST:-}" ]; then
        log "Waiting for database at ${WORDPRESS_DB_HOST}..."
        
        # Extract host and port
        DB_HOST=$(echo "$WORDPRESS_DB_HOST" | cut -d: -f1)
        DB_PORT=$(echo "$WORDPRESS_DB_HOST" | grep -o ':[0-9]*$' | sed 's/://' || echo "3306")
        
        # Wait for database to be available
        timeout=30
        count=0
        while ! nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null && [ $count -lt $timeout ]; do
            count=$((count + 1))
            log "Database not ready, waiting... ($count/$timeout)"
            sleep 1
        done
        
        if [ $count -ge $timeout ]; then
            log_error "Database failed to become available within $timeout seconds"
            exit 1
        fi
        
        log "Database is available"
    fi
}

# Install WordPress if needed
install_wordpress() {
    if [ "${WORDPRESS_AUTO_INSTALL:-false}" = "true" ]; then
        log "Checking if WordPress installation is needed..."
        
        # Check if WordPress is already installed
        if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
            log "Installing WordPress..."
            
            wp core install \
                --path=/var/www/html \
                --url="${WORDPRESS_URL:-http://localhost:8080}" \
                --title="${WORDPRESS_TITLE:-WordPress Site}" \
                --admin_user="${WORDPRESS_ADMIN_USER:-admin}" \
                --admin_password="${WORDPRESS_ADMIN_PASSWORD:-password}" \
                --admin_email="${WORDPRESS_ADMIN_EMAIL:-admin@example.com}" \
                --allow-root \
                || log_error "WordPress installation failed"
        else
            log "WordPress is already installed"
        fi
    fi
}

# Update WordPress permissions
fix_permissions() {
    log "Setting WordPress file permissions..."
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    find /var/www/html -type f -exec chmod 644 {} \;
    
    # Special permissions for wp-config.php
    if [ -f /var/www/html/wp-config.php ]; then
        chmod 600 /var/www/html/wp-config.php
    fi
    
    # Writable directories
    chmod -R 775 /var/www/html/wp-content
    if [ -d /var/www/html/wp-content/uploads ]; then
        chmod -R 775 /var/www/html/wp-content/uploads
    fi
}

# Main execution
main() {
    log "Starting WordPress container initialization..."
    
    # Setup WordPress configuration
    setup_wordpress
    
    # Wait for database if configured
    wait_for_db
    
    # Install WordPress if requested
    install_wordpress
    
    # Fix permissions
    fix_permissions
    
    log "WordPress container initialization complete"
    
    # Start the command passed to the container
    if [ $# -gt 0 ]; then
        log "Starting command: $*"
        exec "$@"
    else
        log "No command specified"
        exit 1
    fi
}

# Handle special cases
if [ "${1:-}" = "wp" ]; then
    # WP-CLI command
    shift
    exec wp "$@" --allow-root --path=/var/www/html
elif [ "${1:-}" = "bash" ] || [ "${1:-}" = "sh" ]; then
    # Shell access
    exec "$@"
else
    # Normal startup
    main "$@"
fi