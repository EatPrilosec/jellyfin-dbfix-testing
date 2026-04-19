# jellyfin-dbfix-testing Docker build

This repository builds a Docker image from the `Shadowghost/jellyfin` fork using the `perf-rebased` branch.

## Image name

Use this image in your YAML as:

```yaml
jellyfin:
  image: ghcr.io/eatprilosec/jellyfin:latest
  ports:
    - 8096:8096
  volumes:
    - ./config:/config
    - ./cache:/cache
```

## GitHub Actions

The workflow at `.github/workflows/docker-build-push.yml`:

- clones `https://github.com/Shadowghost/jellyfin.git` branch `perf-rebased`
- builds Jellyfin with .NET 10.0
- pushes `ghcr.io/jellyfin-dbfix-testing/jellyfin:latest` to GitHub Container Registry

## Setup

No external Docker Hub credentials are required.

The workflow uses the built-in GitHub token to publish to GitHub Container Registry.

Then push to `main` or `master`, or run the workflow manually.
