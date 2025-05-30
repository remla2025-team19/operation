# operation

This is the central repository that contains all information about running the application and operating the cluster.

Group-name: remla2025-team19

You can find all of our repos, by searching org:remla2025-team19 on GitHub.

Links to the code files:

1. App-frontend: https://github.com/remla2025-team19/app-frontend
2. App-service: https://github.com/remla2025-team19/app-service
3. Lib-version: https://github.com/remla2025-team19/lib-version
4. Model-service: https://github.com/remla2025-team19/model-service
5. Model-training: https://github.com/remla2025-team19/model-training
6. Lib-ML: https://github.com/remla2025-team19/lib-ml
7. Operation: https://github.com/remla2025-team19/operation

## Instructions to run the application:

Kindly use the docker-compose file in the operation repository.

Simply execute the command:

```bash
docker compose up
```

This will start the web application, after which you can send your queries to https://localhost:8080

## Major tasks to be completed, refined

1. Automated tagging of images. Currently we have a push based trigger.
2. Better handling of ML weights? We currently store them as GitHub releases.
3. Improved functionality of lib-version

## Instructions for assignment 2

1. Provision the cluster

```bash
vagrant up
```

2. Finalize the cluster

```bash
ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization.yml
```

## Instructions for assignment 3

1. To apply the k8s resources. Set the image version tags in [kubernetes/kustomization.yaml](./kubernetes/kustomization.yaml) then use the following command:

```bash
kubectl apply -k kubernetes/
```

In case of issues, restart minikube.

```bash
minikube stop
minikube start
```

2. To set install Helm
   Run the command

```bash
helm install sentiment-analyzer-1 ./helm/sentiment-analyzer/ --set app.ingress.host=app1.local
```

To install another instance for the same cluster, be sure the names are changes. For example,

```bash
helm install sentiment-analyzer-2 ./helm/sentiment-analyzer/ --set app.ingress.host=app2.local --set model.service.port=5002
```

All the requirements are met:

-   [x] Helm chart `Chart.yaml` exists in `helm/sentiment-analyzer/`
-   [x] Covers the deployment (app-service and model-service) using `helm/sentiment-analyzer/templates`
-   [x] Service name can be changed via `helm/sentiment-analyzer/values.yaml`
-   [x] Helm chart can be installed more than once. All resources use the prefic {{ .Release.Name }}

Install Prometheus and Grafana using the following command:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Create namespace + CRDs + Prometheus/Alertmanager/Grafana:

```bash
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

## Accessing the Kubernetes Dashboard

After running the finalization playbook, the Kubernetes Dashboard will be available at:

**URL:** https://dashboard.local

### Prerequisites

1. Add the following to your `/etc/hosts` file:

    ```
    192.168.56.90 dashboard.local
    ```

2. Get the authentication token (run on the control node):

    ```bash
    # SSH into the ctrl VM
    ssh vagrant@192.168.56.100

    # Get the token
    kubectl -n kubernetes-dashboard get secret admin-user-token -o jsonpath='{.data.token}' | base64 -d
    ```

3. Copy the token and use it to log into the dashboard at https://dashboard.local

### Alternative Access Methods

**Port Forward (without ingress):**

```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

**Debug service issues:**

```bash
# Check if dashboard services are running
kubectl -n kubernetes-dashboard get svc

# Check dashboard pods
kubectl -n kubernetes-dashboard get pods

# Re-apply dashboard configuration
kubectl apply -f ansible/k8s/dashboard.yml
```

Then access via: https://localhost:8443

**Get Token (alternative method):**

```bash
kubectl -n kubernetes-dashboard create token admin-user
```
