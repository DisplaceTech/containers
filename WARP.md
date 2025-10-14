# Warp Rules for Containers Project

## Project Overview
This project creates container images for open source applications, inspired by Bitnami's container library but with our own approach:
- GitHub CI/CD builds images and pushes to GitHub Container Registry (GHCR)  
- Focus on WordPress stack: Apache, PHP-FPM, MariaDB, WordPress
- Use Alpine Linux as the base image for all containers
- Semantic versioning with latest tags

## Container Image Standards

### Base Image Strategy
- Always use Alpine Linux as the base (currently Alpine 3.22)
- Keep Dockerfiles minimal and secure
- Include health checks for all services
- Use multi-stage builds where appropriate

### Tagging Strategy
- `latest` tag always points to the most recent stable version
- Version-specific tags (e.g., `apache:2.4.65`) for reproducibility
- For WordPress: matrix tags like `wordpress:6.8.3-php8.3`
- Tags are NOT immutable - rebuilds with newer Alpine overwrite same version tags
- Only when major versions change do we preserve older version tags

### Directory Structure
```
containers/
├── apache/           # Apache web server
├── php-fpm/          # PHP-FPM variants
├── mariadb/          # MariaDB database
├── wordpress/        # WordPress with PHP matrix
├── .github/          # GitHub Actions and templates
├── examples/         # Docker Compose examples
└── docs/             # Additional documentation
```

### Dockerfile Standards
- Include comprehensive metadata labels
- Use specific package versions where possible
- Create non-root users for security
- Optimize layer caching
- Include comprehensive health checks
- Document all exposed ports and volumes

## Development Practices

### Git Workflow
- Commit changes incrementally as work progresses
- Stage changes for manual review before pushing
- Use descriptive commit messages following conventional commits
- Never push automatically - always stage for user review

### Testing Strategy  
- Each image should have basic functionality tests
- Include Docker Compose examples for integration testing
- Validate health checks work properly
- Test matrix builds for WordPress variants

### CI/CD Requirements
- Automatically detect all container directories
- Build and push to GHCR on main branch pushes
- Support manual triggers for specific images
- Include proper error handling and notifications
- Use build caching where possible

## Security Standards
- Run containers as non-root users where possible
- Use specific Alpine package versions
- Enable Dependabot for security updates
- Implement proper secret management for registry access
- Follow Docker security best practices

## Documentation Requirements
- Each container directory needs its own README with usage examples
- Main README should cover getting started with GHCR
- Include comprehensive Docker Compose examples
- Document all environment variables and configuration options
- Provide troubleshooting guides

## Container-Specific Rules

### Apache
- Version: 2.4.65 on Alpine 3.22
- Tags: `apache:latest`, `apache:2.4.65`
- Include standard modules and security hardening
- Support for custom configurations via volumes

### PHP-FPM  
- Active PHP versions only: 8.3.26 and 8.4.13
- Tags: `php-fpm:latest` (→8.4.13), `php-fpm:8.3`, `php-fpm:8.3.26`, `php-fpm:8.4`, `php-fpm:8.4.13`
- Include common extensions for WordPress
- Optimized php.ini configuration

### MariaDB
- Latest stable version on Alpine 3.22
- Standard database initialization scripts
- Proper data volume configuration
- Health checks for database readiness

### WordPress
- Version 6.8.3 built against multiple PHP versions
- Tags: `wordpress:6.8.3-php8.3`, `wordpress:6.8.3-php8.4`
- Include WP-CLI for management
- Optimized for performance and security

## File Organization
- Keep related files together in container directories
- Use consistent naming conventions
- Include .dockerignore files appropriately
- Organize GitHub Actions workflows logically

## Code Quality
- Validate all Dockerfiles with hadolint or similar
- Use shellcheck for any shell scripts
- Maintain consistent formatting and style
- Include proper error handling in all scripts

## Licensing
- All Dockerfiles use MIT license
- Copyright 2025 Displace Technologies
- Include proper attribution for base images
- Document any third-party components used