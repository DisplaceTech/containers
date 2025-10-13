# PHP-FPM Container

High-performance PHP-FPM containers optimized for WordPress development, available in multiple PHP versions.

## Available Versions

- **PHP 8.4.13** (latest) - `ghcr.io/displacetech/php-fpm:latest`
- **PHP 8.3.26** - `ghcr.io/displacetech/php-fpm:8.3`

Both versions include all essential extensions for WordPress development.

## Quick Start

```bash
# Run PHP-FPM 8.4 (latest)
docker run -d -p 9000:9000 ghcr.io/displacetech/php-fpm:latest

# Run PHP-FPM 8.3
docker run -d -p 9000:9000 ghcr.io/displacetech/php-fpm:8.3

# Run with custom code
docker run -d -p 9000:9000 -v $(pwd):/var/www/html ghcr.io/displacetech/php-fpm:8.4
```

## Features

- 🐘 **Multiple PHP Versions**: PHP 8.4.13 and 8.3.26
- 🔒 **Security Hardened**: Non-root user, secure configurations
- 📦 **WordPress Optimized**: All necessary extensions included
- 🚀 **Performance Tuned**: OPcache enabled, optimized settings
- 🏥 **Health Monitoring**: Built-in health checks
- 📝 **Comprehensive Logging**: Access, error, and slow query logs

## Included PHP Extensions

All containers include these WordPress-essential extensions:

- **Core**: opcache, json, openssl, curl, zlib
- **Database**: mysqli, pdo, pdo_mysql
- **XML/HTML**: xml, xmlwriter, xmlreader, simplexml, dom
- **Text**: mbstring, iconv, ctype, filter
- **Graphics**: gd, exif, imagick
- **Utilities**: zip, intl, bcmath, fileinfo, tokenizer
- **Session**: session, hash
- **Security**: sodium, posix
- **Caching**: redis

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PHP_MEMORY_LIMIT` | `256M` | PHP memory limit |
| `PHP_MAX_EXECUTION_TIME` | `300` | Maximum script execution time |
| `PHP_UPLOAD_MAX_SIZE` | `64M` | Maximum upload file size |
| `PHP_POST_MAX_SIZE` | `64M` | Maximum POST data size |
| `FPM_PM_MAX_CHILDREN` | `50` | Maximum FPM children processes |

### Volumes

| Path | Description |
|------|-------------|
| `/var/www/html` | Web application root directory |
| `/var/log/php-fpm` | PHP-FPM log files |
| `/etc/php84/conf.d` | PHP configuration overrides (8.4) |
| `/etc/php83/conf.d` | PHP configuration overrides (8.3) |

### Ports

| Port | Description |
|------|-------------|
| `9000` | PHP-FPM FastCGI |

## Usage with Web Servers

### With Apache

```yaml
version: '3.8'
services:
  web:
    image: ghcr.io/displacetech/apache:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/var/www/html
    depends_on:
      - php

  php:
    image: ghcr.io/displacetech/php-fpm:8.4
    volumes:
      - ./html:/var/www/html
```

### With Nginx

```yaml
version: '3.8'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/var/www/html
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - php

  php:
    image: ghcr.io/displacetech/php-fpm:8.4
    volumes:
      - ./html:/var/www/html
```

Example Nginx configuration:
```nginx
server {
    listen 80;
    root /var/www/html;
    index index.php index.html;

    location ~ \.php$ {
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

## WordPress Stack

Complete WordPress setup with MariaDB:

```yaml
version: '3.8'
services:
  wordpress:
    image: ghcr.io/displacetech/apache:latest
    ports:
      - "8080:80"
    volumes:
      - ./wordpress:/var/www/html
    depends_on:
      - php
      - mariadb

  php:
    image: ghcr.io/displacetech/php-fpm:8.4
    volumes:
      - ./wordpress:/var/www/html
    environment:
      PHP_MEMORY_LIMIT: 512M
    depends_on:
      - mariadb

  mariadb:
    image: ghcr.io/displacetech/mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    volumes:
      - mariadb_data:/var/lib/mysql

volumes:
  mariadb_data:
```

## Performance Tuning

### OPcache Settings

The containers come with optimized OPcache settings:

```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=2
```

### Process Management

FPM is configured with dynamic process management:

- **pm.max_children**: 50
- **pm.start_servers**: 5
- **pm.min_spare_servers**: 5
- **pm.max_spare_servers**: 35

### Custom Configuration

Override PHP settings by mounting custom configuration:

```bash
docker run -d -p 9000:9000 \
  -v $(pwd)/custom.ini:/etc/php84/conf.d/custom.ini \
  -v $(pwd):/var/www/html \
  ghcr.io/displacetech/php-fpm:8.4
```

Example custom.ini:
```ini
memory_limit = 512M
max_execution_time = 600
upload_max_filesize = 100M
post_max_size = 100M
```

## Security Features

- **Non-root execution**: Runs as user `www-data` (UID/GID 1001)
- **Function restrictions**: Dangerous functions disabled
- **Session security**: Secure session cookie settings
- **File upload limits**: Reasonable upload size limits
- **Error handling**: Errors logged, not displayed

## Health Monitoring

### Health Check

Built-in health check validates PHP-FPM configuration:

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' <container_name>
```

### Logs

Access different types of logs:

```bash
# PHP-FPM error logs
docker exec <container> tail -f /var/log/php-fpm/error.log

# PHP error logs
docker exec <container> tail -f /var/log/php-fpm/www-error.log

# Access logs
docker exec <container> tail -f /var/log/php-fpm/access.log

# Slow query logs
docker exec <container> tail -f /var/log/php-fpm/slow.log
```

## Development Tools

### PHP Info

Access PHP configuration at `/index.php` when no other index file exists.

### Debug Mode

Enable debug logging:

```bash
docker run -d -p 9000:9000 \
  -v $(pwd)/debug.ini:/etc/php84/conf.d/debug.ini \
  ghcr.io/displacetech/php-fpm:8.4
```

debug.ini:
```ini
display_errors = On
error_reporting = E_ALL
log_errors = On
```

## Version-Specific Tags

- `ghcr.io/displacetech/php-fpm:latest` → PHP 8.4.13
- `ghcr.io/displacetech/php-fpm:8.4` → PHP 8.4.13
- `ghcr.io/displacetech/php-fpm:8.4.13` → PHP 8.4.13
- `ghcr.io/displacetech/php-fpm:8.3` → PHP 8.3.26
- `ghcr.io/displacetech/php-fpm:8.3.26` → PHP 8.3.26

## Migration Guide

### From PHP 8.3 to 8.4

1. Update your Docker Compose file:
   ```yaml
   php:
     image: ghcr.io/displacetech/php-fpm:8.4
   ```

2. Test your application thoroughly
3. Update any version-specific configurations

### Version Compatibility

Both PHP versions are configured identically and should be drop-in replacements for most WordPress applications.

## Troubleshooting

### Common Issues

1. **Permission errors**
   ```bash
   # Fix file permissions
   chown -R 1001:1001 /path/to/html
   ```

2. **Memory limit exceeded**
   ```bash
   # Increase memory limit
   -e PHP_MEMORY_LIMIT=512M
   ```

3. **Slow responses**
   ```bash
   # Check slow log
   docker exec <container> tail -f /var/log/php-fpm/slow.log
   ```

### Debug Container

Run in interactive mode for debugging:

```bash
docker run -it --rm \
  -v $(pwd):/var/www/html \
  ghcr.io/displacetech/php-fpm:8.4 \
  /bin/sh
```

## License

This container configuration is licensed under the MIT License.

PHP is licensed under the PHP License.
See: https://www.php.net/license/