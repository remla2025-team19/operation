# Grafana Setup
This folder explains how to setup the Grafana dashboard to view custom metrics for the application.

## Dashboard Terminology
This dashboard includes the following metrics:
- Gauge panel to see the number of requests receieved in `app_requests_total`
- Time series graphs for: checking the request rate over time `rate(app_requests_total[$interval])` and the average latency `avg(model_latency_seconds)`.

## Content
- `dashboard.json` Contains and defines the layout of the dashboard
- `dashboard-confimap.yaml` Contains Kubernetes ConfigMap to install the dashboard

## Importing to UI
The dashboard can be visualised automatically or manually.
- Ensure your Kubernetes cluster is running - Grafana will be installed. 
- Ensure prometheus is installed.
- If not available already, port forward Grafana using: `kubectl port-forward svc/grafana -n grafana 3000:3000`
- Open Grafana in browser at: `http://localhost:3000`
- Upload your `dashboard.json` after hovering over the `+` in the left panel. 
- Select `Prometheus` as data source and import.

- You can also automatically deploy it via a ConfigMap by applying: 
```bash
kubectl apply -f ansible/grafana/dashboard-configmap.yaml