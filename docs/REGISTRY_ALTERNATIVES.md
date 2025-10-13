# Container Registry Alternatives

If you're hitting GitHub Container Registry storage limits, here are alternatives:

## Docker Hub (Recommended)

**Free Tier:**
- **Unlimited public repositories**
- **200 MB** per image layer
- **6 hours** for automated builds

**Setup:**
1. Create account at hub.docker.com
2. Add Docker Hub credentials to GitHub Secrets:
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`
3. Update registry in workflow:
   ```yaml
   env:
     REGISTRY: docker.io
     REGISTRY_NAMESPACE: yourusername
   ```

## Other Options

### Quay.io
- **Unlimited public repositories**
- Good security scanning
- RedHat backed

### AWS ECR Public
- **500 GB** free storage
- AWS integration
- Good for production

### DigitalOcean Container Registry
- **5 GB** free with DigitalOcean account
- Simple integration

## Cost Comparison

| Registry | Free Storage | Free Bandwidth | Public Repos |
|----------|--------------|----------------|--------------|
| GHCR | 500 MB | 1 GB | Unlimited |
| Docker Hub | Unlimited | Unlimited | 1 (unlimited public) |
| Quay.io | Unlimited | Unlimited | Unlimited |
| AWS ECR Public | 500 GB | 500 GB | Unlimited |

## Recommendation

For open source projects like yours, **Docker Hub** is the best choice due to unlimited public storage.