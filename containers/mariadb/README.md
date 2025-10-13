# MariaDB Container

High-performance MariaDB Server optimized for WordPress development and production use.

## Quick Start

```bash
# Run MariaDB with root password
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=rootpass ghcr.io/displacetech/mariadb:latest

# Run with database and user creation
docker run -d -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=wordpress \
  -e MYSQL_USER=wpuser \
  -e MYSQL_PASSWORD=wppass \
  ghcr.io/displacetech/mariadb:latest

# Run with persistent storage
docker run -d -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -v mariadb_data:/var/lib/mysql \
  ghcr.io/displacetech/mariadb:latest
```

## Features

- 🛢️ **Latest MariaDB**: MariaDB 11.5 on Alpine Linux
- 🔒 **Security Hardened**: Non-root user, secure defaults
- 📦 **WordPress Optimized**: UTF8MB4, optimized settings
- 🚀 **Performance Tuned**: InnoDB optimizations, query cache
- 🏥 **Health Monitoring**: Built-in health checks
- 📝 **Comprehensive Logging**: Error and slow query logs
- 🔧 **Flexible Initialization**: Support for custom SQL scripts

## Environment Variables

### Required (choose one)

| Variable | Description |
|----------|-------------|
| `MYSQL_ROOT_PASSWORD` | Root password for MariaDB |
| `MYSQL_RANDOM_ROOT_PASSWORD=yes` | Generate random root password |
| `MYSQL_ALLOW_EMPTY_PASSWORD=yes` | Allow empty root password (not recommended) |

### Optional Database Setup

| Variable | Default | Description |
|----------|---------|-------------|
| `MYSQL_DATABASE` | | Database to create on startup |
| `MYSQL_USER` | | Non-root user to create |
| `MYSQL_PASSWORD` | | Password for the non-root user |

### Example Configurations

**WordPress Setup:**
```bash
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_password
```

**Development Setup:**
```bash
MYSQL_ROOT_PASSWORD=devpass
MYSQL_DATABASE=myapp
MYSQL_USER=developer
MYSQL_PASSWORD=devpass
```

## Volumes

| Path | Description |
|------|-------------|
| `/var/lib/mysql` | Database data files |
| `/var/log/mysql` | MariaDB log files |
| `/docker-entrypoint-initdb.d` | Initialization scripts |

## Ports

| Port | Description |
|------|-------------|
| `3306` | MySQL/MariaDB protocol |

## Docker Compose Example

### WordPress Stack

```yaml
version: '3.8'
services:
  wordpress:
    image: ghcr.io/displacetech/wordpress:6.8.3-php8.4
    ports:
      - "8080:8080"
    environment:
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - mariadb

  mariadb:
    image: ghcr.io/displacetech/mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - mariadb_data:/var/lib/mysql
      - mariadb_logs:/var/log/mysql
    restart: unless-stopped

volumes:
  wordpress_data:
  mariadb_data:
  mariadb_logs:
```

### Development Stack

```yaml
version: '3.8'
services:
  app:
    image: ghcr.io/displacetech/php-fpm:8.4
    volumes:
      - ./app:/var/www/html
    depends_on:
      - database

  database:
    image: ghcr.io/displacetech/mariadb:latest
    ports:
      - "3306:3306"  # Expose for external tools
    environment:
      MYSQL_ROOT_PASSWORD: devpass
      MYSQL_DATABASE: myapp
      MYSQL_USER: developer
      MYSQL_PASSWORD: devpass
    volumes:
      - ./initdb:/docker-entrypoint-initdb.d:ro
      - mariadb_dev:/var/lib/mysql

volumes:
  mariadb_dev:
```

## Database Initialization

The container supports automatic database initialization using scripts placed in `/docker-entrypoint-initdb.d/`:

### Supported Script Types

- **`.sql`** - SQL scripts executed directly
- **`.sql.gz`** - Compressed SQL scripts
- **`.sh`** - Shell scripts (executable or sourced)

### Example Usage

```bash
# Mount initialization scripts
docker run -d -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=myapp \
  -v $(pwd)/initdb:/docker-entrypoint-initdb.d:ro \
  -v mariadb_data:/var/lib/mysql \
  ghcr.io/displacetech/mariadb:latest
```

**Example initialization script (`initdb/01-schema.sql`):**
```sql
-- Create additional tables
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email) VALUES 
    ('admin', 'admin@example.com'),
    ('user1', 'user1@example.com');
```

## Performance Configuration

### Memory Settings

The container comes with optimized settings for typical WordPress usage:

- **InnoDB Buffer Pool**: 128MB (adjust based on available memory)
- **Query Cache**: 16MB
- **Max Connections**: 200

### Custom Configuration

Override settings by mounting a custom configuration file:

```bash
docker run -d -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -v $(pwd)/custom.cnf:/etc/my.cnf.d/custom.cnf:ro \
  ghcr.io/displacetech/mariadb:latest
```

**Example custom.cnf:**
```ini
[mysqld]
# Increase buffer pool for high-memory systems
innodb_buffer_pool_size = 512M

# Increase max connections for high-traffic sites
max_connections = 500

# Disable query cache if using application-level caching
query_cache_type = 0
query_cache_size = 0
```

## Security Features

- **Non-root execution**: Runs as user `mysql` (UID 100/GID 101)
- **Secure defaults**: Anonymous users and test database removed
- **Network security**: Configurable bind address
- **Password requirements**: Strong password enforcement options

## Monitoring and Logging

### Health Check

Built-in health check monitors database availability:

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' <container_name>
```

### Log Access

Access various log files:

```bash
# Error logs
docker exec <container_name> tail -f /var/log/mysql/error.log

# Slow query logs (queries > 2 seconds)
docker exec <container_name> tail -f /var/log/mysql/slow.log

# General query log (if enabled)
docker exec <container_name> tail -f /var/log/mysql/general.log
```

### Performance Monitoring

```bash
# Check database status
docker exec <container_name> mariadb-admin status

# View process list
docker exec -it <container_name> mariadb -uroot -p -e "SHOW PROCESSLIST;"

# Check InnoDB status
docker exec -it <container_name> mariadb -uroot -p -e "SHOW ENGINE INNODB STATUS\G"
```

## Database Operations

### Backup

```bash
# Create database backup
docker exec <container_name> mariadb-dump -uroot -p --all-databases > backup.sql

# Backup specific database
docker exec <container_name> mariadb-dump -uroot -p myapp > myapp_backup.sql
```

### Restore

```bash
# Restore from backup
docker exec -i <container_name> mariadb -uroot -p < backup.sql

# Restore specific database
docker exec -i <container_name> mariadb -uroot -p myapp < myapp_backup.sql
```

### Connect to Database

```bash
# Connect as root
docker exec -it <container_name> mariadb -uroot -p

# Connect as specific user
docker exec -it <container_name> mariadb -uusername -p database_name
```

## High Availability & Replication

The container includes basic replication configuration. For master-slave setup:

**Master Configuration:**
```yaml
services:
  mariadb-master:
    image: ghcr.io/displacetech/mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: masterpass
    volumes:
      - ./master.cnf:/etc/my.cnf.d/replication.cnf:ro
```

**master.cnf:**
```ini
[mysqld]
server-id = 1
log-bin = mysql-bin
binlog-do-db = myapp
```

## Troubleshooting

### Common Issues

1. **Container won't start**
   ```bash
   # Check logs
   docker logs <container_name>
   
   # Verify environment variables
   docker inspect <container_name>
   ```

2. **Connection refused**
   ```bash
   # Check if port is exposed
   docker port <container_name>
   
   # Verify bind address in configuration
   docker exec <container_name> grep bind-address /etc/my.cnf.d/custom.cnf
   ```

3. **Slow performance**
   ```bash
   # Check slow query log
   docker exec <container_name> tail -f /var/log/mysql/slow.log
   
   # Monitor resource usage
   docker stats <container_name>
   ```

### Debug Mode

Run with additional logging:

```bash
docker run -d -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -v $(pwd)/debug.cnf:/etc/my.cnf.d/debug.cnf:ro \
  ghcr.io/displacetech/mariadb:latest
```

**debug.cnf:**
```ini
[mysqld]
log-error-verbosity = 3
slow_query_log = 1
long_query_time = 1
log_queries_not_using_indexes = 1
```

## Tags and Versioning

- `ghcr.io/displacetech/mariadb:latest` - Latest stable MariaDB
- `ghcr.io/displacetech/mariadb:11.5` - Specific version
- `ghcr.io/displacetech/mariadb:11` - Major version

## Migration Guide

### From MySQL

MariaDB is largely compatible with MySQL. Most applications work without changes.

### From Other MariaDB Versions

1. Backup your data
2. Update the container image
3. Start the container (automatic upgrades will run)
4. Verify functionality

## License

This container configuration is licensed under the MIT License.

MariaDB Server is licensed under the GPL v2.
See: https://mariadb.org/about/legal/