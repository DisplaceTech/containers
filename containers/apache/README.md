# Apache HTTP Server Container

Apache HTTP Server 2.4.65 running on Alpine Linux 3.22, optimized for containerized environments.

## Quick Start

```bash
# Run Apache with default configuration
docker run -d -p 8080:80 ghcr.io/displacetech/apache:latest

# Run with custom content
docker run -d -p 8080:80 -v $(pwd)/html:/var/www/html ghcr.io/displacetech/apache:latest

# Run with SSL support
docker run -d -p 8080:80 -p 8443:443 \
  -v $(pwd)/certs:/etc/ssl/certs \
  -v $(pwd)/private:/etc/ssl/private \
  ghcr.io/displacetech/apache:latest
```

## Features

- 🔒 **Security Hardened**: Non-root user, security headers, minimal modules
- 📦 **Lightweight**: Based on Alpine Linux for minimal footprint
- 🔧 **Configurable**: Support for custom configurations via volumes
- 🏥 **Health Checks**: Built-in health monitoring
- 📝 **SSL Ready**: Pre-configured SSL/TLS settings

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `APACHE_RUN_USER` | `apache` | User to run Apache as |
| `APACHE_RUN_GROUP` | `apache` | Group to run Apache as |
| `APACHE_LOG_LEVEL` | `warn` | Apache log level |

### Volumes

| Path | Description |
|------|-------------|
| `/var/www/html` | Document root for web content |
| `/etc/apache2/conf.d` | Additional Apache configuration |
| `/var/log/apache2` | Apache log files |
| `/etc/ssl/certs` | SSL certificates |
| `/etc/ssl/private` | SSL private keys |

### Ports

| Port | Protocol | Description |
|------|----------|-------------|
| `80` | HTTP | Standard web traffic |
| `443` | HTTPS | Secure web traffic |

## Docker Compose Example

```yaml
version: '3.8'
services:
  web:
    image: ghcr.io/displacetech/apache:latest
    ports:
      - "8080:80"
      - "8443:443"
    volumes:
      - ./html:/var/www/html
      - ./conf:/etc/apache2/conf.d
      - ./logs:/var/log/apache2
      - ./certs:/etc/ssl/certs:ro
      - ./private:/etc/ssl/private:ro
    restart: unless-stopped
```

## SSL/TLS Configuration

To enable HTTPS:

1. Mount your certificates:
   ```bash
   -v /path/to/certs:/etc/ssl/certs:ro
   -v /path/to/private:/etc/ssl/private:ro
   ```

2. Create a custom virtual host configuration in `/etc/apache2/conf.d/`:
   ```apache
   <VirtualHost *:443>
       ServerName example.com
       DocumentRoot /var/www/html
       
       SSLEngine on
       SSLCertificateFile /etc/ssl/certs/server.crt
       SSLCertificateKeyFile /etc/ssl/private/server.key
       
       # Optional: Certificate chain
       # SSLCertificateChainFile /etc/ssl/certs/ca-bundle.crt
   </VirtualHost>
   ```

## Security Features

- **Non-root execution**: Runs as user `apache` (UID/GID 1001)
- **Security headers**: X-Content-Type-Options, X-Frame-Options, etc.
- **Minimal modules**: Only essential modules loaded
- **File access restrictions**: Sensitive files blocked by default
- **Modern TLS**: TLS 1.2+ only, secure cipher suites

## Health Check

The container includes a built-in health check that verifies Apache is responding:

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' <container_name>
```

## Logs

Access logs via Docker:

```bash
# View logs
docker logs <container_name>

# Follow logs
docker logs -f <container_name>

# Access specific log files
docker exec <container_name> tail -f /var/log/apache2/access.log
docker exec <container_name> tail -f /var/log/apache2/error.log
```

## Advanced Configuration

### Custom Apache Configuration

Mount custom configuration files:

```bash
docker run -d -p 8080:80 \
  -v $(pwd)/custom.conf:/etc/apache2/conf.d/custom.conf \
  ghcr.io/displacetech/apache:latest
```

### Performance Tuning

For high-traffic sites, consider tuning these parameters in your custom configuration:

```apache
# Increase worker limits
StartServers 4
MinSpareServers 4
MaxSpareServers 20
MaxRequestWorkers 300
MaxConnectionsPerChild 2000

# Optimize KeepAlive
KeepAlive On
MaxKeepAliveRequests 200
KeepAliveTimeout 2
```

### Reverse Proxy Configuration

Use as a reverse proxy:

```apache
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so

<VirtualHost *:80>
    ServerName example.com
    
    ProxyPass / http://backend:8080/
    ProxyPassReverse / http://backend:8080/
    
    ProxyPreserveHost On
    ProxyAddHeaders On
</VirtualHost>
```

## Troubleshooting

### Common Issues

1. **Permission denied errors**
   - Ensure volume permissions allow access by user ID 1001
   - Check: `chown -R 1001:1001 /path/to/html`

2. **SSL certificate errors**
   - Verify certificate paths in virtual host configuration
   - Ensure certificate files are readable by container

3. **Module not found**
   - Check if required modules are loaded in httpd.conf
   - Use `docker exec <container> httpd -M` to list loaded modules

### Debug Mode

Run in debug mode for troubleshooting:

```bash
docker run -it --rm -p 8080:80 \
  -e APACHE_LOG_LEVEL=debug \
  ghcr.io/displacetech/apache:latest
```

## Tags and Versioning

- `ghcr.io/displacetech/apache:latest` - Latest stable version
- `ghcr.io/displacetech/apache:2.4.65` - Specific Apache version
- `ghcr.io/displacetech/apache:2.4` - Apache 2.4 series

## License

This container configuration is licensed under the MIT License.

The Apache HTTP Server software is licensed under the Apache License 2.0.
See: https://httpd.apache.org/docs/2.4/license.html