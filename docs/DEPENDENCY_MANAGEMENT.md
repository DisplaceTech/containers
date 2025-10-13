# Dependency Management Strategy

This document outlines our approach to managing dependencies in the container library, including Dependabot configuration and maintenance practices.

## Dependabot Configuration

Our Dependabot configuration is designed to scale efficiently as we add more containers without requiring manual updates to the configuration file.

### Key Design Principles

1. **Single Directory Monitoring**: Instead of listing each container individually, we monitor the entire `/containers` directory. Dependabot automatically discovers all Dockerfiles recursively.

2. **Intelligent Grouping**: Updates are grouped by technology stack to reduce PR noise:
   - `alpine-updates`: All Alpine Linux base image updates
   - `php-updates`: PHP-related package updates
   - `apache-updates`: Apache/httpd package updates  
   - `mariadb-updates`: MariaDB/MySQL package updates

3. **Noise Reduction**: We ignore patch-level updates (`semver-patch`) to focus on security and feature updates that matter more.

4. **Reasonable Limits**: Maximum 10 open PRs to prevent overwhelming the team.

### Benefits of This Approach

- **Automatic Discovery**: New containers are automatically monitored without config changes
- **Reduced Noise**: Grouping and filtering prevents dozens of minor update PRs
- **Security Focus**: Prioritizes security updates over minor patches
- **Scalable**: Works whether you have 5 containers or 50

## Container Versioning Strategy

### Base Images
- **Alpine Linux**: Pin to specific versions (e.g., `alpine:3.22`)
- **Application Images**: Use specific version tags, not `latest`

### Package Versions
- **Alpine Packages**: Pin to specific versions with release numbers (e.g., `php83=8.3.26-r0`)
- **Downloaded Binaries**: Pin to specific versions (e.g., WordPress, WP-CLI)

### Version Update Process

1. **Automated Discovery**: Dependabot creates PRs for version updates
2. **Testing**: GitHub Actions automatically test container builds
3. **Review**: Team reviews grouped changes together
4. **Merge**: Once approved, changes trigger new image builds
5. **Release**: New images are pushed to GHCR with updated tags

## Best Practices for Adding New Containers

When adding new containers to the library:

### 1. Directory Structure
```
containers/
├── new-service/
│   ├── major.minor/          # e.g., 2.4/ for Apache 2.4.x
│   │   ├── Dockerfile
│   │   ├── config-files...
│   │   └── README.md
│   └── README.md
```

### 2. Dockerfile Requirements
- Pin all package versions with release numbers
- Use multi-stage builds where appropriate
- Include comprehensive health checks
- Add proper LABEL metadata
- Create non-root users for security

### 3. Version Management
- Use build args for configurable versions
- Document version update process in container README
- Test version compatibility before updates

## Monitoring and Alerts

### Security Updates
- Dependabot flags security vulnerabilities automatically
- Security updates get higher priority (not filtered out)
- Critical security updates should be applied immediately

### Version Compatibility
- Test matrix builds for version combinations (e.g., WordPress + PHP versions)
- Maintain compatibility matrices in documentation
- Use integration tests to verify container interactions

## Maintenance Schedule

### Weekly
- Review and merge Dependabot PRs
- Check for any failed builds or tests
- Update documentation if needed

### Monthly  
- Review overall dependency health
- Check for EOL versions that need migration
- Update version compatibility matrices

### Quarterly
- Review and optimize Dependabot configuration
- Audit container security practices
- Plan major version migrations

## Scaling Considerations

As the container library grows:

### Configuration Management
- Use build arg templates for consistency
- Consider shared base images for common setups
- Implement automated testing for all containers

### CI/CD Optimization
- Use build matrix strategies for related containers
- Implement smart build triggering (only build changed containers)
- Cache layers efficiently across builds

### Documentation
- Maintain clear README files for each container
- Document inter-container dependencies
- Keep upgrade guides updated

## Troubleshooting

### Common Issues

1. **Too Many PRs**: Adjust grouping patterns or ignore rules
2. **Failed Builds**: Check for breaking changes in base images
3. **Version Conflicts**: Review compatibility matrices and test thoroughly

### Getting Help

- Check GitHub Issues for similar problems
- Review Dependabot logs in PR descriptions
- Test locally using `make build-all` before merging

---

This strategy ensures our dependency management remains sustainable and secure as we scale from a handful of containers to dozens or more.