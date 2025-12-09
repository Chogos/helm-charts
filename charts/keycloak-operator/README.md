# Keycloak Operator Helm Chart

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 26.4.7](https://img.shields.io/badge/AppVersion-26.4.7-informational?style=flat-square)

A Helm chart for deploying the Keycloak Operator on Kubernetes.

## Description

The Keycloak Operator simplifies the deployment and management of Keycloak instances on Kubernetes. It provides custom resources for Keycloak, KeycloakRealm, and KeycloakRealmImport, automating the configuration and lifecycle management of Keycloak deployments.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+

## Installing the Chart

To install the chart with the release name `keycloak-operator`:

```bash
helm install keycloak-operator ./charts/keycloak-operator
```

## Uninstalling the Chart

To uninstall the `keycloak-operator` deployment:

```bash
helm uninstall keycloak-operator
```

## Configuration

The following table lists the configurable parameters of the Keycloak Operator chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Keycloak Operator image repository | `quay.io/keycloak/keycloak-operator` |
| `image.tag` | Keycloak Operator image tag (defaults to Chart appVersion) | `""` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Image pull secrets for private registries | `[]` |
| `nameOverride` | Override for the chart name | `""` |
| `fullnameOverride` | Override for the full chart name | `""` |
| `rbac.create` | Create RBAC resources | `true` |
| `serviceAccount.create` | Create ServiceAccount | `true` |
| `serviceAccount.name` | ServiceAccount name (uses generated name if empty) | `""` |
| `serviceAccount.annotations` | Additional ServiceAccount annotations | `{}` |
| `podAnnotations` | Additional pod annotations | `{}` |
| `resources.limits.memory` | Memory limit | `450Mi` |
| `resources.limits.cpu` | CPU limit | `700m` |
| `resources.requests.memory` | Memory request | `450Mi` |
| `resources.requests.cpu` | CPU request | `300m` |
| `startupProbe.initialDelaySeconds` | Startup probe initial delay | `5` |
| `startupProbe.periodSeconds` | Startup probe period | `10` |
| `startupProbe.timeoutSeconds` | Startup probe timeout | `10` |
| `startupProbe.failureThreshold` | Startup probe failure threshold | `3` |
| `startupProbe.successThreshold` | Startup probe success threshold | `1` |
| `livenessProbe.initialDelaySeconds` | Liveness probe initial delay | `5` |
| `livenessProbe.periodSeconds` | Liveness probe period | `10` |
| `livenessProbe.timeoutSeconds` | Liveness probe timeout | `10` |
| `livenessProbe.failureThreshold` | Liveness probe failure threshold | `3` |
| `livenessProbe.successThreshold` | Liveness probe success threshold | `1` |
| `readinessProbe.initialDelaySeconds` | Readiness probe initial delay | `5` |
| `readinessProbe.periodSeconds` | Readiness probe period | `10` |
| `readinessProbe.timeoutSeconds` | Readiness probe timeout | `10` |
| `readinessProbe.failureThreshold` | Readiness probe failure threshold | `3` |
| `readinessProbe.successThreshold` | Readiness probe success threshold | `1` |
| `nodeSelector` | Node selector for pod assignment | `{}` |
| `tolerations` | Tolerations for pod assignment | `[]` |
| `affinity` | Affinity configuration | `{}` |
| `env` | Additional environment variables | `[]` |
| `watchNamespace` | Namespace the operator should watch (empty means the namespace where it's installed) | `""` |
| `additionalLabels` | Additional labels to add to all resources | `{}` |
| `additionalAnnotations` | Additional annotations to add to all resources | `{}` |

## Examples

### Install in a specific namespace

```bash
helm install keycloak-operator ./charts/keycloak-operator --namespace keycloak-system --create-namespace
```

### Watch a specific namespace

```bash
helm install keycloak-operator ./charts/keycloak-operator \
  --set watchNamespace=my-keycloak-namespace
```

## Troubleshooting

### Check operator logs

```bash
kubectl logs -l app.kubernetes.io/name=keycloak-operator
```

### Check operator health

```bash
kubectl port-forward svc/keycloak-operator 8080:80
curl http://localhost:8080/q/health/ready
```

### Common issues

- **RBAC permissions**: Ensure the ServiceAccount has the necessary cluster permissions if `rbac.create=false`
- **Namespace watching**: If `watchNamespace` is set, ensure the operator is deployed with appropriate permissions in that namespace
- **Image pull issues**: Check `imagePullSecrets` configuration for private registries

## More Information

- [Keycloak Operator Documentation](https://www.keycloak.org/operator/basic-deployment)
- [Keycloak GitHub](https://github.com/keycloak/keycloak)
- [Helm Documentation](https://helm.sh/docs/)
