# GitOps

## Ziel

Das Repository ist die führende Quelle für Kubernetes-Objekte.

## Struktur

- `k8s/platform/argocd/` enthält die Root- und Child-Applications
- `k8s/platform/observability/` enthält Plattform-Manifeste
- `k8s/platform/external-secrets/` enthält Secret-Integration
- `k8s/apps/` enthält Team- oder Produkt-Workloads

## Ablauf

1. Änderungen werden per Pull Request eingecheckt
2. GitHub validiert Renderbarkeit und Policies
3. Argo CD synchronisiert auf das Zielcluster
