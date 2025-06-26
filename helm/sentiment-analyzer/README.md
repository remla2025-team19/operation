# Sentiment Analyzer Helm Chart

A flexible Helm chart for deploying the Sentiment Analyzer application with support for both simple ingress-based deployments and advanced Istio service mesh canary deployments.

## Chart Architecture

This chart supports two deployment modes:

### 1. Ingress Controller Mode (`istio.enabled: false`)

-   **Use case**: Simple production deployment with NGINX ingress
-   **Traffic routing**: Standard Kubernetes Ingress to stable version only
-   **Files used**: `templates/app.yaml`, `templates/model.yaml`, `templates/ingress.yaml`

### 2. Istio Service Mesh Mode (`istio.enabled: true`)

-   **Use case**: Advanced canary deployments and traffic splitting
-   **Traffic routing**: Istio Gateway/VirtualService with weight-based routing
-   **Files used**: `templates/app.yaml`, `templates/model.yaml`, `templates/istio.yaml`

## Chart Structure

```
helm/sentiment-analyzer/
├── Chart.yaml                 # Chart metadata
├── values.yaml               # Base configuration + additional releases
├── templates/
│   ├── app.yaml              # App service deployments (base + additional)
│   ├── model.yaml            # Model service deployments (base + additional)
│   ├── ingress.yaml          # Standard K8s Ingress (istio.enabled: false)
│   ├── istio.yaml            # Istio Gateway/VirtualService (istio.enabled: true)
│   ├── servicemonitor.yaml   # Prometheus monitoring
│   └── prometheus-rules.yaml # Custom metrics rules
├── grafana-values.yaml       # Grafana dashboard configuration
└── README.md                 # This file
```

## Configuration Structure

The chart uses a **base + additional releases** pattern:

```yaml
# Base stable release (always deployed)
versionLabel: v1
app:
    image:
        tag: 'v0.0.22'
    service:
        port: 80
        targetPort: 8080
    ingress:
        host: app.local
        className: 'nginx'
    resources:
        limits:
            memory: '512Mi'
            cpu: '500m'

model:
    image:
        tag: 'v0.0.9'
    service:
        port: 5001
    config:
        version: 'v1.0.11'
        predictionThreshold: 0.75
    resources:
        limits:
            memory: '512Mi'
            cpu: '500m'

# Istio canary releases (deployed when istio.enabled: true)
istio:
    enabled: true
    baseWeight: 90 # Traffic % for stable version
    additionalReleases:
        - versionLabel: v2
          weight: 10 # Traffic % for this version
          experimentHeader: 'canary' # Optional header-based routing
          app:
              image:
                  tag: 'latest' # Override app image
          model:
              image:
                  tag: 'latest' # Override model image
              config:
                  predictionThreshold: 0.8 # Override model settings

storage:
    modelCache:
        path: '/mnt/shared/model_cache' # Host path
        mountPath: '/app/model_cache' # Container mount path
```

## Installation

### Prerequisites

```bash
# Add to /etc/hosts for local testing
192.168.56.90 dashboard.local grafana.local restaurant.local
192.168.56.91 app.local
```

### Option 1: Ingress-based Deployment

For basic deployments with standard Kubernetes ingress:

```bash
helm install my-app ./helm/sentiment-analyzer/ \
  --set istio.enabled=false \
  --set app.ingress.host=restaurant.local
```

### Option 2: Istio-based Deployment

For advanced canary deployments with traffic splitting:

```bash
helm install my-app ./helm/sentiment-analyzer/ \
  --set istio.enabled=true \
  --set app.ingress.host=app.local
```

### Option 3: Custom Canary Configuration

Deploy with custom traffic weights and model settings:

```bash
helm install my-experiment ./helm/sentiment-analyzer/ \
  --set istio.enabled=true \
  --set istio.baseWeight=80 \
  --set istio.additionalReleases[0].weight=20 \
  --set istio.additionalReleases[0].model.config.predictionThreshold=0.9
```

### Option 4: Multiple Instances

Deploy multiple instances on the same cluster:

```bash
# Instance 1
helm install sentiment-analyzer-prod ./helm/sentiment-analyzer/ \
  --set app.ingress.host=app-prod.local \
  --set model.service.port=5001

# Instance 2
helm install sentiment-analyzer-staging ./helm/sentiment-analyzer/ \
  --set app.ingress.host=app-staging.local \
  --set model.service.port=5002
```

## Traffic Routing Behavior

### Istio Mode Traffic Distribution

1. **Base version (v1)**: Receives `baseWeight` percentage of traffic (default: 90%)
2. **Additional releases**: Each receives their configured `weight` percentage (default: 1 canary release with 10%)
3. **Header-based routing**: Requests with `X-Experiment: <name>` always route to the specified experiment (default: `canary` routes to v2)
4. **Sticky sessions**: Users with the same `X-User` header consistently hit the same version
5. **Version consistency**: Requests from the app service will always be routed to the model service with the same version label (e.g., app-v1 -> model-v1)

### Example Traffic Flow

```yaml
# Configuration
istio:
    baseWeight: 85
    additionalReleases:
        - versionLabel: v2
          weight: 10
          experimentHeader: 'canary'
        - versionLabel: v3
          weight: 5
```

**Traffic distribution:**

-   85% → v1 (base)
-   10% → v2
-   5% → v3
-   100% → v2 (when `X-Experiment: canary` header present)

## Model Artifact Management

Model artifacts are automatically downloaded from the url matching the version string and cached in a shared volume:

```yaml
# Input configuration
model:
    config:
        version: 'v1.0.11'
# Auto-generated URL
# https://github.com/remla2025-team19/model-training/releases/download/v1.0.11/sentiment_model_v1.0.11.pkl

# Cache location:
storage:
    modelCache:
        path: '/mnt/shared/model_cache' # Host path
        mountPath: '/app/model_cache' # Container mount path
```

## Configuration Inheritance

Additional releases inherit base configuration and override only specified values:

```yaml
# Base configuration
app:
    image:
        tag: 'v0.0.22'
    resources:
        limits:
            memory: '512Mi'

# Additional release (inherits everything except overrides)
istio:
    additionalReleases:
        - versionLabel: v2
          app:
              image:
                  tag: 'latest' # Only overrides tag
              # resources inherited from base
```

## Monitoring and Observability

### Prometheus Metrics

The chart automatically configures:

-   Request rates by version
-   Response times by version
-   Custom business metrics (e.g., number of responses by sentiment)
-   ServiceMonitor for automatic discovery

### Grafana Dashboard

Import the pre-built dashboard:

1. Access Grafana at `http://grafana.local`
2. Login: `admin` / `prom-operator`
3. Import `dashboard/dashboard.json`

### Kiali (Istio only)

View service mesh topology, from the ctrl plane:

```bash
ssh vagrant@192.168.56.100
istioctl dashboard kiali --address 0.0.0.0
# Access at http://192.168.56.100:20001
```

## Testing Istio Deployments

Example commands to generate traffic:

```bash
# Normal traffic (distributed by weight)
curl -H 'Host: app.local' -H 'X-User: alice' http://192.168.56.91

# Force canary traffic
curl -H 'Host: app.local' -H 'X-Experiment: canary' http://192.168.56.91

# Sticky session testing
for i in {1..10}; do
  curl -H 'Host: app.local' -H 'X-User: bob' -H "Content-Type: application/json" -d '{"query": "disgusting"}' http://192.168.56.91/api/query
done
```

## Troubleshooting

### Check Deployment Status

```bash
# List all releases
helm list

# Check deployment status
kubectl get deployments -l app.kubernetes.io/instance=my-app

# Check Istio configuration
kubectl get gateway,virtualservice,destinationrule
```

### Common Issues

1. **No Gateway/VirtualService**: Ensure `istio.enabled=true`
2. **Traffic not splitting**: Check weights sum to 100 and pods are ready
3. **Ingress not working**: Verify `istio.enabled=false` and ingress class

### Clean Uninstall

```bash
# Remove Helm release
helm uninstall my-app

# Clean up any orphaned resources
kubectl delete all,configmaps,secrets,ingress,pvc,pv \
  -l app.kubernetes.io/instance=my-app
```

## Development

### Chart Requirements

-   Kubernetes 1.20+
-   Helm 3.0+
-   Istio 1.15+ (for Istio mode)
-   Prometheus Operator (for monitoring)

### Testing Changes

```bash
# Dry run
helm upgrade --install --dry-run my-app ./helm/sentiment-analyzer/

# Template rendering
helm template my-app ./helm/sentiment-analyzer/

# Install with debug
helm upgrade --install --debug my-app ./helm/sentiment-analyzer/
```

### Chart Requirements Met

-   [x] Helm chart with proper `Chart.yaml`
-   [x] Deploys both app-service and model-service
-   [x] Configurable via `values.yaml`
-   [x] Supports multiple installations with unique names
-   [x] Uses `{{ .Release.Name }}` prefix for all resources
-   [x] Supports both Ingress and Istio deployment modes
-   [x] Implements canary deployments with traffic splitting
-   [x] Automatic model artifact URL generation
-   [x] Comprehensive monitoring and observability
