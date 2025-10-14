# Container Images

This directory contains all the container image definitions for the Displace Technologies Container Library.

## Directory Structure

Each container has its own directory with versioned subdirectories to maintain clean separation between different versions:

```
containers/
├── apache/
│   ├── README.md          # Apache container documentation
│   └── 2.4/              # Apache 2.4.x series
│       ├── Dockerfile
│       ├── httpd.conf
│       └── ssl.conf
├── mariadb/
│   ├── README.md          # MariaDB container documentation
│   └── 11.5/             # MariaDB 11.5.x series
│       ├── Dockerfile
│       ├── docker-entrypoint.sh
│       └── my.cnf
├── php-fpm/
│   ├── README.md          # PHP-FPM container documentation
│   ├── 8.3/              # PHP 8.3.x series
│   │   ├── Dockerfile
│   │   ├── php.ini
│   │   ├── php-fpm.conf
│   │   └── www.conf
│   └── 8.4/              # PHP 8.4.x series
│       ├── Dockerfile
│       ├── php.ini
│       ├── php-fpm.conf
│       └── www.conf
└── wordpress/
    ├── README.md          # WordPress container documentation
    ├── 6.8.3-php8.3/     # WordPress 6.8.3 with PHP 8.3
    │   ├── Dockerfile
    │   ├── httpd.conf
    │   ├── php.ini
    │   ├── wp-config-docker.php
    │   ├── wp-cli.yml
    │   └── docker-entrypoint.sh
    └── 6.8.3-php8.4/     # WordPress 6.8.3 with PHP 8.4
        ├── Dockerfile
        ├── httpd.conf
        ├── php.ini
        ├── wp-config-docker.php
        ├── wp-cli.yml
        └── docker-entrypoint.sh
```

## Available Images

### Apache Web Server
- **Location**: `apache/2.4/`
- **Tags**: `apache:latest`, `apache:2.4.65`
- **Description**: Apache HTTP Server 2.4.65 with security hardening

### PHP-FPM
- **Location**: `php-fpm/8.3/` and `php-fpm/8.4/`
- **Tags**: `php-fpm:latest` (8.4), `php-fpm:8.4`, `php-fpm:8.3`
- **Description**: PHP-FPM with WordPress-optimized extensions

### MariaDB
- **Location**: `mariadb/11.5/`
- **Tags**: `mariadb:latest`, `mariadb:11.5`
- **Description**: MariaDB database server optimized for WordPress

### WordPress
- **Location**: `wordpress/6.8.3-php8.3/` and `wordpress/6.8.3-php8.4/`
- **Tags**: `wordpress:6.8.3-php8.3`, `wordpress:6.8.3-php8.4`
- **Description**: Complete WordPress installation with Apache and PHP

## Building Images

Each versioned directory contains everything needed to build that specific image:

```bash
# Build Apache 2.4
docker build -t ghcr.io/DisplaceTech/apache:2.4.65 containers/apache/2.4/

# Build PHP-FPM 8.4
docker build -t ghcr.io/DisplaceTech/php-fpm:8.4.13 containers/php-fpm/8.4/

# Build MariaDB 11.5
docker build -t ghcr.io/DisplaceTech/mariadb:11.5 containers/mariadb/11.5/

# Build WordPress with PHP 8.4
docker build -t ghcr.io/DisplaceTech/wordpress:6.8.3-php8.4 containers/wordpress/6.8.3-php8.4/
```

## Container Features

All containers include:

- 🔒 **Security hardened** with non-root users
- 🏔️ **Alpine Linux** base for minimal footprint  
- 🏥 **Health checks** for monitoring
- 📝 **Comprehensive logging** and error handling
- 📚 **Detailed documentation** and examples
- 🐳 **Docker Compose** ready configurations

## Version Management

- **Immutable versions**: Version-specific tags (e.g., `apache:2.4.65`) are preserved
- **Mutable latest**: `latest` tags are updated with new builds
- **Alpine updates**: Rebuilds with newer Alpine versions overwrite same version tags
- **Major version preservation**: Only major version changes preserve old version tags

## Getting Started

See the main project README for complete usage instructions and Docker Compose examples.

Each container directory contains its own README with detailed configuration options and usage examples.