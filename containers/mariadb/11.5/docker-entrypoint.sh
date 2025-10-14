#!/bin/sh
set -eo pipefail

# Docker entrypoint for MariaDB
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

# Check if we're running as mysql user
if [ "$(id -u)" != "100" ]; then
    log_error "Container must run as user mysql (UID 100)"
    exit 1
fi

# Function to generate random password
generate_password() {
    pwgen -s 32 1
}

# Function to execute SQL
mysql_exec() {
    mariadb --protocol=socket --socket=/run/mysqld/mysqld.sock --silent "$@"
}

# Function to check if MariaDB is ready
mysql_ready() {
    mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1
}

# Function to wait for MariaDB to be ready
wait_for_mysql() {
    local timeout=30
    local count=0
    
    while ! mysql_ready && [ $count -lt $timeout ]; do
        count=$((count + 1))
        log "Waiting for MariaDB to be ready... ($count/$timeout)"
        sleep 1
    done
    
    if [ $count -ge $timeout ]; then
        log_error "MariaDB failed to start within $timeout seconds"
        exit 1
    fi
    
    log "MariaDB is ready"
}

# Function to initialize database
init_database() {
    log "Starting temporary MariaDB instance for setup..."
    
    # Start MariaDB in background for initialization
    mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    mysql_pid=$!
    
    wait_for_mysql
    
    log "Setting up initial database configuration..."
    
    # Secure installation steps
    mysql_exec <<-EOSQL
        DELETE FROM mysql.user WHERE user='';
        DELETE FROM mysql.user WHERE user='root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
        DELETE FROM mysql.db WHERE db='test' OR db='test\_%';
        FLUSH PRIVILEGES;
EOSQL

    # Set root password if provided
    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        log "Setting root password..."
        mysql_exec <<-EOSQL
            ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
            CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
            GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
            FLUSH PRIVILEGES;
EOSQL
    elif [ "$MYSQL_ALLOW_EMPTY_PASSWORD" != "yes" ] && [ "$MYSQL_RANDOM_ROOT_PASSWORD" = "yes" ]; then
        log "Generating random root password..."
        MYSQL_ROOT_PASSWORD=$(generate_password)
        mysql_exec <<-EOSQL
            ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
            CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
            GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
            FLUSH PRIVILEGES;
EOSQL
        log "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
        log "Please save this password!"
    elif [ "$MYSQL_ALLOW_EMPTY_PASSWORD" != "yes" ]; then
        log_error "No root password set and MYSQL_ALLOW_EMPTY_PASSWORD is not 'yes'"
        log_error "Please set MYSQL_ROOT_PASSWORD or MYSQL_RANDOM_ROOT_PASSWORD=yes"
        exit 1
    fi
    
    # Create database if specified
    if [ -n "$MYSQL_DATABASE" ]; then
        log "Creating database '$MYSQL_DATABASE'..."
        mysql_exec <<-EOSQL
            CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOSQL
    fi
    
    # Create user if specified
    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        log "Creating user '$MYSQL_USER'..."
        mysql_exec <<-EOSQL
            CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
EOSQL
        
        if [ -n "$MYSQL_DATABASE" ]; then
            log "Granting privileges to '$MYSQL_USER' on database '$MYSQL_DATABASE'..."
            mysql_exec <<-EOSQL
                GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
                FLUSH PRIVILEGES;
EOSQL
        fi
    elif [ -n "$MYSQL_USER" ] || [ -n "$MYSQL_PASSWORD" ]; then
        log_warn "Both MYSQL_USER and MYSQL_PASSWORD must be set to create a user"
    fi
    
    # Execute initialization scripts
    for f in /docker-entrypoint-initdb.d/*; do
        if [ -f "$f" ]; then
            log "Executing initialization script: $f"
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        log "Executing $f"
                        "$f"
                    else
                        log "Sourcing $f"
                        . "$f"
                    fi
                    ;;
                *.sql)
                    log "Executing SQL file $f"
                    mysql_exec < "$f"
                    ;;
                *.sql.gz)
                    log "Executing compressed SQL file $f"
                    gunzip -c "$f" | mysql_exec
                    ;;
                *)
                    log_warn "Ignoring $f (not a .sh, .sql, or .sql.gz file)"
                    ;;
            esac
        fi
    done
    
    log "Database initialization complete"
    
    # Stop the temporary instance
    if ! kill -s TERM "$mysql_pid" || ! wait "$mysql_pid"; then
        log_error "Failed to stop temporary MariaDB instance"
        exit 1
    fi
}

# Main execution
if [ "${1:0:1}" = '-' ]; then
    set -- mariadbd "$@"
fi

if [ "$1" = 'mariadbd' ] || [ "$1" = 'mysqld' ]; then
    # Ensure directories exist and have correct permissions
    mkdir -p /var/lib/mysql /var/log/mysql /run/mysqld
    
    # Initialize MariaDB data directory if it doesn't exist
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        log "Database not found, installing..."
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
        log "Database installation completed"
    fi
    
    # Check if database needs configuration (always run for environment variables)
    log "Database found, initializing..."
    init_database
    log "Database initialization completed"
    
    log "Starting MariaDB server..."
fi

# Execute the main command
exec "$@"