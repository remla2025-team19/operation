# AGENT.md - Operations Repository Guide

## Commands

### Workflow guidelines

-   The ansible/ dirctory is the main dir used for provisioning, check it first.
-   Every admin command must run on the control node (192.168.56.100)

### Docker Compose

-   Start application: `docker compose up`
-   Stop application: `docker compose down`

### Vagrant/VM Management

-   Provision cluster: `vagrant up`
-   Finalize cluster: `ansible-playbook -u vagrant -i 192.168.56.100, ansible/finalization.yml`
-   SSH into ctrl node: `ssh vagrant@192.168.56.100`

### Kubernetes

-   Apply k8s resources: `kubectl apply -k kubernetes/`
-   Restart minikube: `minikube stop && minikube start`

### Helm

-   Install chart: `helm install sentiment-analyzer ./helm/sentiment-analyzer/ --set app.ingress.host=app.local`
-   Install monitoring: `helm upgrade --install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace`

## Code Style Guidelines

-   Use YAML for configuration files with 2-space indentation
-   Follow Kubernetes resource naming: lowercase, hyphenated
-   Use semantic versioning for image tags in kustomization.yaml
-   Prefix Helm resources with `{{ .Release.Name }}`
-   Store sensitive data in ansible/ssh_keys/ (gitignored)
-   Use meaningful commit messages referencing issue/PR numbers
-   Make sure the steps in the ansible playbooks are idempotent
