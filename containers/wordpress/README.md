# WordPress Container

Complete WordPress 6.8.3 installation with Apache and PHP, optimized for performance and security.

## Available Versions

- **WordPress 6.8.3 + PHP 8.4** - `ghcr.io/displacetech/wordpress:6.8.3-php8.4`
- **WordPress 6.8.3 + PHP 8.3** - `ghcr.io/displacetech/wordpress:6.8.3-php8.3`

Both versions include:
- Apache 2.4.65 web server
- WordPress 6.8.3 with WP-CLI 2.12.0
- Optimized PHP configuration
- Security hardening and health checks

## Quick Start

```bash
# Run WordPress with PHP 8.4
docker run -d -p 8080:8080 \
  -e WORDPRESS_DB_HOST=mariadb \
  -e WORDPRESS_DB_NAME=wordpress \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wppass \
  ghcr.io/displacetech/wordpress:6.8.3-php8.4

# Run with auto-installation
docker run -d -p 8080:8080 \
  -e WORDPRESS_DB_HOST=mariadb \
  -e WORDPRESS_DB_NAME=wordpress \
  -e WORDPRESS_DB_USER=wpuser \
  -e WORDPRESS_DB_PASSWORD=wppass \
  -e WORDPRESS_AUTO_INSTALL=true \
  -e WORDPRESS_ADMIN_USER=admin \
  -e WORDPRESS_ADMIN_PASSWORD=secure_password \
  -e WORDPRESS_ADMIN_EMAIL=admin@example.com \
  ghcr.io/displacetech/wordpress:6.8.3-php8.4
```

## Features

- 🚀 **Complete Stack**: WordPress + Apache + PHP in one container
- 🔧 **WP-CLI Included**: WordPress command-line interface for management
- 🔒 **Security Hardened**: Non-root execution, file permissions, security headers
- 🏥 **Health Monitoring**: Built-in health checks and comprehensive logging
- ⚡ **Performance Optimized**: OPcache, Apache/PHP tuning, WordPress optimizations
- 🔄 **Auto Installation**: Optional automatic WordPress setup
- 🎯 **Matrix Builds**: Available with both PHP 8.3 and PHP 8.4

## Environment Variables

### Database Configuration (Required)

| Variable | Description |
|----------|-------------|
| `WORDPRESS_DB_HOST` | Database host (e.g., `mariadb:3306`) |
| `WORDPRESS_DB_NAME` | Database name |
| `WORDPRESS_DB_USER` | Database username |
| `WORDPRESS_DB_PASSWORD` | Database password |

### WordPress Configuration (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `WORDPRESS_TABLE_PREFIX` | `wp_` | Database table prefix |
| `WORDPRESS_DEBUG` | `false` | Enable WordPress debug mode |
| `WORDPRESS_DEBUG_LOG` | `false` | Enable debug logging |

### Auto Installation (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `WORDPRESS_AUTO_INSTALL` | `false` | Automatically install WordPress |
| `WORDPRESS_URL` | `http://localhost:8080` | Site URL |
| `WORDPRESS_TITLE` | `WordPress Site` | Site title |
| `WORDPRESS_ADMIN_USER` | `admin` | Admin username |
| `WORDPRESS_ADMIN_PASSWORD` | `password` | Admin password |
| `WORDPRESS_ADMIN_EMAIL` | `admin@example.com` | Admin email |

### Security Keys (Auto-generated if not provided)

| Variable | Description |
|----------|-------------|
| `WORDPRESS_AUTH_KEY` | Authentication key |
| `WORDPRESS_SECURE_AUTH_KEY` | Secure authentication key |
| `WORDPRESS_LOGGED_IN_KEY` | Logged in key |
| `WORDPRESS_NONCE_KEY` | Nonce key |
| `WORDPRESS_AUTH_SALT` | Authentication salt |
| `WORDPRESS_SECURE_AUTH_SALT` | Secure authentication salt |
| `WORDPRESS_LOGGED_IN_SALT` | Logged in salt |
| `WORDPRESS_NONCE_SALT` | Nonce salt |

## Volumes

| Path | Description |
|------|-------------|
| `/var/www/html` | WordPress installation directory |
| `/var/log/apache2` | Apache and PHP error logs |

## Ports

| Port | Description |
|------|-------------|
| `8080` | WordPress website (HTTP) |

## Complete WordPress Stack

### Docker Compose Example

```yaml
version: '3.8'
services:
  wordpress:
    image: ghcr.io/displacetech/wordpress:6.8.3-php8.4
    ports:
      - "8080:8080"
    environment:
      # Database connection
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      
      # Optional: Auto installation
      WORDPRESS_AUTO_INSTALL: "true"
      WORDPRESS_URL: http://localhost:8080
      WORDPRESS_TITLE: "My WordPress Site"
      WORDPRESS_ADMIN_USER: admin
      WORDPRESS_ADMIN_PASSWORD: secure_password_here
      WORDPRESS_ADMIN_EMAIL: admin@example.com
    volumes:
      - wordpress_data:/var/www/html
      - wordpress_logs:/var/log/apache2
    depends_on:
      - mariadb
    restart: unless-stopped

  mariadb:
    image: ghcr.io/displacetech/mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - mariadb_data:/var/lib/mysql
    restart: unless-stopped

volumes:
  wordpress_data:
  mariadb_data:
  wordpress_logs:
```

### Using with External Database

```yaml
version: '3.8'
services:
  wordpress:
    image: ghcr.io/displacetech/wordpress:6.8.3-php8.4
    ports:
      - "8080:8080"
    environment:
      WORDPRESS_DB_HOST: external-db.example.com:3306
      WORDPRESS_DB_NAME: my_wordpress_db
      WORDPRESS_DB_USER: wp_user
      WORDPRESS_DB_PASSWORD: secure_db_password
    volumes:
      - ./wordpress:/var/www/html
```

## WP-CLI Usage

The container includes WP-CLI for WordPress management:

```bash
# Run WP-CLI commands
docker exec -it <container_name> wp --help

# List plugins
docker exec -it <container_name> wp plugin list

# Install a plugin
docker exec -it <container_name> wp plugin install contact-form-7 --activate

# Update WordPress core
docker exec -it <container_name> wp core update

# Create a database backup
docker exec -it <container_name> wp db export backup.sql
```

## PHP Version Comparison

### WordPress 6.8.3 + PHP 8.4 (Latest)
- **Image**: `wordpress:6.8.3-php8.4`
- **Features**: Latest PHP performance improvements and features
- **Recommended**: For new deployments

### WordPress 6.8.3 + PHP 8.3 (Stable)
- **Image**: `wordpress:6.8.3-php8.3`
- **Features**: Mature, stable PHP version
- **Recommended**: For compatibility with older plugins/themes

Both versions have identical WordPress and Apache configurations.

## Performance Tuning

### PHP Optimizations
- OPcache enabled with WordPress-specific settings
- Memory limit: 256MB (configurable)
- Upload limit: 64MB (configurable)
- Execution time: 300 seconds

### Apache Optimizations
- Process management tuned for containers
- Security headers enabled
- WordPress-friendly URL rewriting
- File upload protections

### WordPress Optimizations
- WP_CACHE enabled for plugin compatibility
- Automatic updates enabled
- Optimized file permissions
- Security hardening

## Security Features

- **Non-root execution**: Runs as www-data user
- **File permissions**: Proper WordPress file permissions
- **Security headers**: X-Frame-Options, X-XSS-Protection, etc.
- **Upload protection**: PHP execution disabled in uploads directory
- **Access restrictions**: Sensitive files blocked
- **Function restrictions**: Dangerous PHP functions disabled

## Logging and Monitoring

### Log Files
```bash
# View Apache access logs
docker exec <container> tail -f /var/log/apache2/access.log

# View Apache error logs
docker exec <container> tail -f /var/log/apache2/error.log

# View PHP error logs
docker exec <container> tail -f /var/log/apache2/php_errors.log
```

### Health Check
The container includes built-in health checks:

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' <container_name>
```

## Development vs Production

### Development Setup
```bash
docker run -d -p 8080:8080 \
  -e WORDPRESS_DEBUG=true \
  -e WORDPRESS_DEBUG_LOG=true \
  -v $(pwd)/wp-content:/var/www/html/wp-content \
  -e WORDPRESS_DB_HOST=mariadb \
  ghcr.io/displacetech/wordpress:6.8.3-php8.4
```

### Production Setup
```bash
docker run -d -p 8080:8080 \
  -e WORDPRESS_DEBUG=false \
  -v wordpress_data:/var/www/html \
  -e WORDPRESS_DB_HOST=prod-db.internal:3306 \
  --restart=unless-stopped \
  ghcr.io/displacetech/wordpress:6.8.3-php8.4
```

## Troubleshooting

### Common Issues

1. **Database connection errors**
   ```bash
   # Check database connectivity
   docker exec <container> nc -z $WORDPRESS_DB_HOST 3306
   ```

2. **Permission errors**
   ```bash
   # Fix WordPress permissions
   docker exec <container> chown -R www-data:www-data /var/www/html
   ```

3. **Plugin/theme installation issues**
   ```bash
   # Check file permissions on wp-content
   docker exec <container> ls -la /var/www/html/wp-content/
   ```

### Debug Mode

Enable debug logging for troubleshooting:

```bash
docker run -d -p 8080:8080 \
  -e WORDPRESS_DEBUG=true \
  -e WORDPRESS_DEBUG_LOG=true \
  ghcr.io/displacetech/wordpress:6.8.3-php8.4
```

Then check debug logs:
```bash
docker exec <container> tail -f /var/www/html/wp-content/debug.log
```

## Building from Source

### PHP 8.4 Version
```bash
cd containers/wordpress/6.8.3-php8.4
docker build -t my-wordpress:6.8.3-php8.4 .
```

### PHP 8.3 Version
```bash
cd containers/wordpress/6.8.3-php8.3
docker build -t my-wordpress:6.8.3-php8.3 .
```

## License

This container configuration is licensed under the MIT License.

WordPress is licensed under the GPL v2 or later.
See: https://wordpress.org/about/license/