# Platform Setup

Infrastructure and Kubernetes manifests for the LAB510 workshop environment.

## Directory Layout

```
src/
├── infra/          # Terraform for provisioning Azure resources
│   └── main.tf     # Root Terraform configuration
└── manifests/      # Kubernetes manifests deployed via Argo CD
    ├── app-of-apps.yaml   # Argo CD root Application
    ├── airunway/          # AI Runway controller and provider configs
    ├── argocd/            # Argo CD bootstrap resources
    └── lustre/            # Lustre CSI driver manifests
```

## infra/

Terraform configuration that provisions the lab environment: resource group, AKS cluster with CPU and GPU node pools, Azure Managed Lustre storage, and Helm releases for the GPU operator, Istio, Prometheus, and Argo CD. See the [infrastructure setup instructions](../docs/README.md#lab-infrastructure-setup) in the workshop guide for usage.

> [!IMPORTANT]
> This configuration requires an Azure subscription with sufficient vCPU quota for the GPU VM SKU (Standard_NC48ads_A100_v4). Request quota increases in advance since approvals can take time.

## manifests/

Kubernetes manifests managed by Argo CD using an app-of-apps pattern. The root `app-of-apps.yaml` bootstraps all child applications (AI Runway, KAITO, Dynamo, Gateway API, KubeRay, Lustre CSI). These are applied automatically during cluster provisioning. You'll reference and modify individual manifests in the workshop modules.
