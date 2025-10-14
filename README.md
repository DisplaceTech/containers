# The Displace Technologies Container Library

Popular projects, fully containerized by [Displace Technologies](https://displace.tech).

## Overview

Welcome to our container library! This project provides production-ready container images for popular open source applications, built with security, performance, and reliability in mind. Our images are automatically built using GitHub CI/CD and hosted on GitHub Container Registry (GHCR).

### Key Features

- 🔒 **Secure**: Built on Alpine Linux with non-root users and security best practices
- 🚀 **Optimized**: Minimal image sizes with efficient layer caching
- 🔄 **Automated**: CI/CD pipeline for automatic builds and updates
- 📦 **WordPress Stack**: Complete LAMP/LEMP stack optimized for WordPress
- 🏷️ **Semantic Versioning**: Clear, predictable tagging strategy

## Quick Start

### Using Images from GHCR

All our images are available on GitHub Container Registry. You can pull them using:

```bash
docker pull ghcr.io/displacetech/apache:latest
docker pull ghcr.io/displacetech/php-fpm:8.4
docker pull ghcr.io/displacetech/mariadb:latest
docker pull ghcr.io/displacetech/wordpress:6.8.3-php8.4
```

### WordPress Stack with Docker Compose

Get a complete WordPress installation running in minutes:

```yaml
# docker-compose.yml
version: '3.8'

services:
  wordpress:
    image: ghcr.io/displacetech/wordpress:6.8.3-php8.4
    ports:
      - "8080:8080"
    environment:
      WORDPRESS_DB_HOST: mariadb
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress_password
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html
    depends_on:
      - mariadb

  mariadb:
    image: ghcr.io/displacetech/mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress_password
    volumes:
      - mariadb_data:/var/lib/mysql

volumes:
  wordpress_data:
  mariadb_data:
```

Run with:
```bash
docker compose up -d
```

Your WordPress site will be available at http://localhost:8080

## Available Images

### Apache Web Server
- **Image**: `ghcr.io/displacetech/apache`
- **Tags**: `latest`, `2.4.65`
- **Base**: Alpine 3.22
- **Exposed Ports**: 80, 443

### PHP-FPM
- **Image**: `ghcr.io/displacetech/php-fpm`
- **Tags**: `latest` (→8.4.13), `8.4`, `8.4.13`, `8.3`, `8.3.26`
- **Base**: Alpine 3.22
- **Exposed Ports**: 9000
- **Extensions**: Common PHP extensions for WordPress development

### MariaDB
- **Image**: `ghcr.io/displacetech/mariadb`
- **Tags**: `latest`, version-specific tags
- **Base**: Alpine 3.22
- **Exposed Ports**: 3306
- **Features**: Optimized configuration, health checks

### WordPress
- **Image**: `ghcr.io/displacetech/wordpress`
- **Tags**: `6.8.3-php8.4`, `6.8.3-php8.3`
- **Base**: Alpine 3.22
- **Exposed Ports**: 8080
- **Features**: WP-CLI included, optimized for performance

## Tagging Strategy

- **`latest`**: Always points to the most recent stable version
- **Version Tags**: Specific versions for reproducible deployments
- **Matrix Tags**: WordPress images include PHP version in the tag
- **Non-Immutable**: Tags may be updated with newer Alpine versions
- **Major Version Preservation**: Only major version changes preserve old tags

## Examples and Documentation

- [Docker Compose Examples](./examples/) - Complete stack configurations
- [Individual Container Docs](./containers/) - Detailed usage for each image
- [Dependency Management](./docs/DEPENDENCY_MANAGEMENT.md) - Scaling strategy for automated updates
- [GitHub Actions](./.github/workflows/) - CI/CD pipeline details

## Contributing

We welcome contributions! Please see our [Pull Request Template](.github/pull_request_template.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with Docker Compose
5. Submit a pull request

### Adding New Images

1. Create a new directory under the project root
2. Add a `Dockerfile` following our standards
3. Include a `README.md` with usage examples
4. Add appropriate labels and health checks
5. Update this main README

## Security

- All images run as non-root users where possible
- Regular security updates via Dependabot
- Alpine Linux base for minimal attack surface
- Specific package versions for reproducibility

## License

The Dockerfiles and configuration files in this repository are licensed under the MIT License.

```
MIT License

Copyright (c) 2025 Displace Technologies

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### Third-Party Software

The container images built from these Dockerfiles contain third-party software components that are subject to their own licenses. Please refer to the individual software documentation for their respective license terms:

- Apache HTTP Server: [Apache License 2.0](https://httpd.apache.org/docs/2.4/license.html)
- PHP: [PHP License](https://www.php.net/license/)
- MariaDB: [GPL v2](https://mariadb.org/about/legal/)
- WordPress: [GPL v2 or later](https://wordpress.org/about/license/)
- Alpine Linux: [Multiple licenses](https://pkgs.alpinelinux.org/packages)

## Support

For questions, issues, or contributions:

- 📝 [Create an Issue](https://github.com/displacetech/containers/issues)
- 💬 [Start a Discussion](https://github.com/displacetech/containers/discussions)
- 🌐 [Visit Our Website](https://displace.tech)
