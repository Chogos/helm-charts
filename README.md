# Chogos Helm Charts

A collection of Helm charts for deploying applications and operators on Kubernetes.

## Charts

| Chart | Type | Version | Description |
| ----- | ---- | ------- | ----------- |
| [base](charts/base) | application | 0.1.0 | Generic application chart for deploying containerized workloads |
| [keycloak-operator](charts/keycloak-operator) | application | 1.0.0 | Deploys the Keycloak operator for managing identity and SSO |
| [kube-core](charts/kube-core) | library | 0.1.0 | Reusable Helm templates for standardized Kubernetes resources |
| [kube-core-test](charts/kube-core-test) | application | 0.1.0 | Test harness for validating the kube-core library |

## Overview

### base

A standalone application chart that provisions a complete workload stack: Deployment, Service, Ingress, HTTPRoute (Gateway API), HPA, PDB, RBAC, ConfigMap, PVC, and Prometheus monitoring resources. Ships with secure defaults (non-root UID 1000, read-only root filesystem, all capabilities dropped).

### kube-core

A library chart that exposes named templates for downstream charts to generate Kubernetes resources. Supports a **service-context model** where each template receives a dict of `context`, `service`, and an optional `name` override — enabling multi-service deployments from a single chart release.

Key features:

- Advanced HPA scaling policies with custom metrics
- Full RBAC and monitoring (ServiceMonitor / PrometheusRule)

### keycloak-operator

Deploys the [Keycloak Operator](https://www.keycloak.org/) (appVersion 26.4.7) with full RBAC, health probes, and resource management. Requires Kubernetes >= 1.19 and Helm >= 3.

## Usage

```bash
# Install the base chart
helm install my-app ./charts/base -f values.yaml

# Install keycloak-operator
helm install keycloak-operator ./charts/keycloak-operator

# Use kube-core as a dependency in your Chart.yaml
# dependencies:
#   - name: kube-core
#     version: 0.1.0
#     repository: "<your-chart-repo>"
```

## Testing

The `kube-core-test` chart validates the library with the [helm-unittest](https://github.com/helm-unittest/helm-unittest) plugin:

```bash
helm unittest ./charts/kube-core-test
```

Test value sets are provided under `charts/kube-core-test/ci/` for minimal, full, and multi-service scenarios.

## Prerequisites

- Kubernetes >= 1.26 (kube-core) / >= 1.19 (keycloak-operator)
- Helm >= 3
