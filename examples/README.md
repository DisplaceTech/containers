# Docker Compose Examples

This directory contains ready-to-use Docker Compose configurations demonstrating various ways to use the Displace Technologies Container Library.

## Available Examples

### 1. Complete WordPress Stack (`wordpress-complete.yml`)

A full-featured WordPress installation with MariaDB, optimized for production use.

**Features:**
- WordPress 6.8.3 with PHP 8.4 and Apache
- MariaDB 11.5 database
- Auto-installation option
- Health checks and logging
- Persistent volumes

**Usage:**
```bash
# Start the stack
docker compose -f examples/wordpress-complete.yml up -d

# View logs
docker compose -f examples/wordpress-complete.yml logs -f

# Stop the stack
docker compose -f examples/wordpress-complete.yml down
```

**Access:**
- WordPress site: http://localhost:8080
- Admin credentials: admin/change_this_password (if auto-install enabled)

### 2. WordPress Development Stack (`wordpress-development.yml`)

A development-friendly WordPress setup with debugging and development tools.

**Features:**
- WordPress 6.8.3 with PHP 8.3 (stable for development)
- Debug logging enabled
- PHPMyAdmin for database management
- Volume mounts for local development
- Database port exposed for external tools

**Usage:**
```bash
# Create development directories
mkdir -p wp-content uploads logs/apache logs/mariadb logs/wordpress dev-db-init

# Start the development stack
docker compose -f examples/wordpress-development.yml up -d

# Access services
echo "WordPress: http://localhost:8080"
echo "PHPMyAdmin: http://localhost:8081"
echo "Database: localhost:3306 (user: developer, pass: devpass123)"
```

**Development Workflow:**
1. Edit themes/plugins in `./wp-content/`
2. Monitor logs in `./logs/`
3. Use PHPMyAdmin for database operations
4. Connect external tools to exposed database port

### 3. Separate Services (`separate-services.yml`)

Demonstrates using individual containers as separate microservices.

**Features:**
- Apache web server
- PHP-FPM 8.4 application server
- MariaDB database
- Redis cache (optional)
- Network segmentation

**Usage:**
```bash
# Create required directories
mkdir -p html apache-config php-config db-init

# Add a simple PHP file
echo '<?php phpinfo(); ?>' > html/index.php

# Start services
docker compose -f examples/separate-services.yml up -d
```

**Access:**
- Web application: http://localhost:8080

## Quick Start Guide

### Prerequisites

- Docker and Docker Compose installed
- Ports 8080, 8081, and 3306 available (modify as needed)

### Running an Example

1. **Choose an example** based on your needs:
   - Production WordPress: `wordpress-complete.yml`
   - Development setup: `wordpress-development.yml`
   - Microservices: `separate-services.yml`

2. **Start the stack:**
   ```bash
   docker compose -f examples/<example-name>.yml up -d
   ```

3. **Check status:**
   ```bash
   docker compose -f examples/<example-name>.yml ps
   ```

4. **View logs:**
   ```bash
   docker compose -f examples/<example-name>.yml logs -f
   ```

5. **Stop when done:**
   ```bash
   docker compose -f examples/<example-name>.yml down
   ```

## Customization

### Environment Variables

Create a `.env` file to override default values:

```bash
# .env file example
MYSQL_ROOT_PASSWORD=my_secure_root_password
WORDPRESS_ADMIN_PASSWORD=my_admin_password
WORDPRESS_DB_PASSWORD=my_db_password
```

Then reference in docker-compose.yml:
```yaml
environment:
  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-default_password}
```

### Volume Customization

For persistent data in production:

```yaml
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      device: /opt/wordpress-data
      o: bind
```

### Network Configuration

For external database connections:

```yaml
services:
  wordpress:
    environment:
      WORDPRESS_DB_HOST: external-db.example.com:3306
      WORDPRESS_DB_NAME: prod_wordpress
      WORDPRESS_DB_USER: wp_prod_user
      WORDPRESS_DB_PASSWORD: secure_prod_password
```

## Production Considerations

### Security

1. **Change default passwords** in all examples
2. **Use secrets management** for sensitive data:
   ```yaml
   services:
     mariadb:
       environment:
         MYSQL_ROOT_PASSWORD_FILE: /run/secrets/mysql_root_password
       secrets:
         - mysql_root_password
   
   secrets:
     mysql_root_password:
       file: ./secrets/mysql_root_password.txt
   ```

3. **Enable SSL/TLS** for production deployments
4. **Restrict network access** using Docker networks

### Performance

1. **Resource limits:**
   ```yaml
   services:
     wordpress:
       deploy:
         resources:
           limits:
             cpus: '1.0'
             memory: 512M
   ```

2. **Database tuning:**
   ```yaml
   mariadb:
     command: --innodb-buffer-pool-size=512M --max-connections=200
   ```

3. **Enable caching** (Redis, Memcached, etc.)

### Monitoring

Add monitoring services:

```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
```

## Troubleshooting

### Common Issues

1. **Port conflicts:**
   ```bash
   # Check what's using the port
   lsof -i :8080
   
   # Change port in docker-compose.yml
   ports:
     - "8081:8080"  # Use 8081 instead
   ```

2. **Permission errors:**
   ```bash
   # Fix file permissions
   sudo chown -R $USER:$USER ./wp-content
   ```

3. **Database connection issues:**
   ```bash
   # Check database container logs
   docker compose logs mariadb
   
   # Test database connection
   docker compose exec wordpress nc -z mariadb 3306
   ```

4. **Container startup failures:**
   ```bash
   # Check container logs
   docker compose logs <service_name>
   
   # Check container health
   docker compose ps
   ```

### Debug Mode

Enable debug logging in WordPress:

```yaml
services:
  wordpress:
    environment:
      WORDPRESS_DEBUG: "true"
      WORDPRESS_DEBUG_LOG: "true"
```

Then check logs:
```bash
docker compose exec wordpress tail -f /var/www/html/wp-content/debug.log
```

## Advanced Examples

### Multi-Stage Deployment

Use different configurations for different environments:

```bash
# Development
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Load Balancing

Add multiple WordPress instances with a load balancer:

```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    depends_on:
      - wordpress1
      - wordpress2

  wordpress1:
    image: ghcr.io/displace-technologies/wordpress:6.8.3-php8.4
    # ... config

  wordpress2:
    image: ghcr.io/displace-technologies/wordpress:6.8.3-php8.4
    # ... config
```

## Support

For issues or questions:

1. Check the [main project documentation](../README.md)
2. Review container-specific documentation in `containers/`
3. Open an issue on GitHub
4. Check Docker and Docker Compose logs for errors

## Contributing

To add new examples:

1. Create a new `.yml` file following the naming convention
2. Include comprehensive comments and documentation
3. Test thoroughly in different environments
4. Update this README with the new example
5. Submit a pull request