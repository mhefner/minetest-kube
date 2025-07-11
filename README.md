# Minetest Kubernetes Server

A containerized Minetest server designed for deployment in Kubernetes environments with NFS persistent storage and ArgoCD GitOps workflow.

## Overview

This project provides a production-ready Minetest server that runs in Kubernetes, leveraging NFS for persistent world data storage and ArgoCD for automated deployment and configuration management.

## Features

- **Kubernetes Native**: Fully containerized and designed for Kubernetes deployment
- **Persistent Storage**: NFS-backed persistent volumes for world data persistence
- **GitOps Ready**: ArgoCD integration for automated deployments
- **Scalable**: Horizontal scaling support for multiple game instances
- **Production Ready**: Health checks, resource limits, and monitoring support

## Prerequisites

- Kubernetes cluster (v1.20+)
- NFS server for persistent storage
- ArgoCD installed in your cluster
- `kubectl` configured to access your cluster

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/mhefner/minetest-kube.git
cd minetest-kube
```

### 2. Configure Storage

Edit the persistent volume configuration to match your NFS server:

```yaml
# Update the NFS server details in your PV manifest
spec:
  nfs:
    server: YOUR_NFS_SERVER_IP
    path: /path/to/minetest/data
```

### 3. Deploy with ArgoCD

Create an ArgoCD application:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: minetest-server
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/mhefner/minetest-kube.git
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: minetest
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 4. Access Your Server

Once deployed, find the external IP or NodePort:

```bash
kubectl get svc -n minetest
```

Connect to your Minetest server using the displayed IP and port.

## Configuration

### Environment Variables

The container supports the following environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `MINETEST_SERVER_NAME` | Server name displayed in server list | `Minetest Kubernetes Server` |
| `MINETEST_PORT` | Server port | `30000` |
| `MINETEST_MAX_CLIENTS` | Maximum concurrent players | `20` |
| `MINETEST_MOTD` | Message of the day | `Welcome to Minetest!` |
| `MINETEST_ADMIN` | Admin username | `admin` |
| `MINETEST_PASSWORD` | Server password (optional) | `` |

### Persistent Storage

The server uses NFS-backed persistent volumes to ensure world data survives pod restarts and migrations. The default mount path is `/var/lib/minetest/.minetest/worlds`.

### Resource Limits

Default resource allocation:

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "2000m"
```

Adjust these values based on your expected player count and world complexity.

## Docker Image

The server runs on the `mhefner1983/minetest_kube` Docker image, which includes:

- Minetest server binary
- Essential mods and configuration
- Health check endpoints
- Optimized for Kubernetes deployment

### Building Custom Images

To build your own image with custom mods or configuration:

```bash
docker build -t your-registry/minetest-custom .
docker push your-registry/minetest-custom
```

Update the image reference in your Kubernetes manifests accordingly.

## Deployment Options

### ArgoCD (Recommended)

ArgoCD provides GitOps-based deployment with automatic synchronization:

1. Fork this repository
2. Customize configurations in your fork
3. Create an ArgoCD application pointing to your fork
4. ArgoCD will automatically deploy and sync changes

### Manual Deployment

For direct kubectl deployment:

```bash
kubectl apply -f manifests/
```

### Helm Chart

A Helm chart is available for more flexible deployments:

```bash
helm install minetest-server ./helm-chart
```

## Monitoring and Logging

### Health Checks

The container includes health check endpoints:

- **Liveness Probe**: `/health/live`
- **Readiness Probe**: `/health/ready`

### Metrics

Prometheus metrics are exposed on port `8080/metrics` for monitoring server performance and player statistics.

### Logging

Logs are written to stdout and can be collected by your Kubernetes logging solution:

```bash
kubectl logs -f deployment/minetest-server -n minetest
```

## Backup and Recovery

### Automated Backups

The server supports automated world backups to external storage:

```bash
# Example backup cronjob
kubectl create job --from=cronjob/minetest-backup minetest-backup-manual
```

### Manual Backup

To manually backup world data:

```bash
kubectl exec -it deployment/minetest-server -- tar -czf /backup/world-$(date +%Y%m%d).tar.gz /var/lib/minetest/.minetest/worlds
```

## Scaling

### Horizontal Scaling

For multiple game instances:

```yaml
spec:
  replicas: 3
```

Note: Each replica will need its own persistent volume and external port.

### Vertical Scaling

Increase resources for higher player counts:

```yaml
resources:
  limits:
    memory: "4Gi"
    cpu: "4000m"
```

## Troubleshooting

### Common Issues

**Pod stuck in Pending state**
- Check NFS server connectivity
- Verify persistent volume configuration
- Ensure sufficient cluster resources

**Players cannot connect**
- Verify service and ingress configuration
- Check firewall rules
- Confirm port forwarding setup

**World data not persisting**
- Verify NFS mount is working
- Check persistent volume claim status
- Review pod logs for permission issues

### Debug Commands

```bash
# Check pod status
kubectl get pods -n minetest

# View logs
kubectl logs -f deployment/minetest-server -n minetest

# Access pod shell
kubectl exec -it deployment/minetest-server -n minetest -- /bin/bash

# Check persistent volume
kubectl describe pv minetest-world-pv
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

Please ensure your changes are tested and documented.

## Security

- Never commit sensitive data like passwords to the repository
- Use Kubernetes secrets for sensitive configuration
- Regularly update the base image for security patches
- Implement network policies to restrict pod communication

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:

- **GitHub Issues**: Report bugs and request features
- **Discussions**: Community support and questions
- **Wiki**: Additional documentation and tutorials

## Related Projects

- [Minetest](https://www.minetest.net/) - The official Minetest project
- [ArgoCD](https://argoproj.github.io/cd/) - GitOps continuous delivery
- [Kubernetes](https://kubernetes.io/) - Container orchestration platform

---

**Maintainer**: [@mhefner](https://github.com/mhefner)  
**Docker Hub**: [mhefner1983/minetest_kube](https://hub.docker.com/r/mhefner1983/minetest_kube)
