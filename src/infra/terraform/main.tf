terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.68.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "=3.1.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "=1.19.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "=3.8.1"
    }
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
    username               = azurerm_kubernetes_cluster.example.kube_config.0.username
    password               = azurerm_kubernetes_cluster.example.kube_config.0.password
    client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
  username               = azurerm_kubernetes_cluster.example.kube_config.0.username
  password               = azurerm_kubernetes_cluster.example.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
  load_config_file       = false
}

variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "Brazil South"
}

variable "github_app_id" {
  description = "GitHub App ID for Argo CD to access private repositories."
  type        = string
  default     = "3545600"
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID for Argo CD to access private repositories."
  type        = string
  default     = "128145028"
}

variable "github_app_private_key_file" {
  description = "File name of the GitHub App private key for Argo CD to access private repositories. Expected to be in the same directory as this Terraform code."
  type        = string
  default     = "msbuildlab510.2026-04-29.private-key.pem"
}

resource "random_integer" "example" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "example" {
  name     = "rg-msbuildlab510"
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-msbuildlab510"
  address_space       = ["10.21.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "lfs" {
  name                 = "lustre"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.21.1.0/24"]
}

resource "azurerm_managed_lustre_file_system" "example" {
  name                   = "lfs-msbuildlab510"
  resource_group_name    = azurerm_resource_group.example.name
  location               = azurerm_resource_group.example.location
  sku_name               = "AMLFS-Durable-Premium-500"
  subnet_id              = azurerm_subnet.lfs.id
  storage_capacity_in_tb = 4
  zones                  = ["2"]

  maintenance_window {
    day_of_week        = "Sunday"
    time_of_day_in_utc = "22:00"
  }
}

resource "azurerm_subnet" "aks_default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.21.2.0/24"]
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "aks-msbuildlab510"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "aks-msbuildlab510"
  kubernetes_version  = "1.35"

  default_node_pool {
    name                 = "default"
    min_count            = 3
    max_count            = 6
    auto_scaling_enabled = true
    vm_size              = "Standard_D4d_v4"
    vnet_subnet_id       = azurerm_subnet.aks_default.id

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "helm_release" "nvidia_gpu_operator" {
  name             = "gpu-operator"
  repository       = "https://helm.ngc.nvidia.com/nvidia"
  chart            = "gpu-operator"
  version          = "v26.3.1"
  namespace        = "gpu-operator"
  create_namespace = true
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = "1.29.2"
  namespace        = "istio-system"
  create_namespace = true
}

resource "helm_release" "istiod" {
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  version          = "1.29.2"
  namespace        = "istio-system"
  create_namespace = false

  set = [
    {
      name  = "pilot.env.ENABLE_GATEWAY_API_INFERENCE_EXTENSION"
      value = "true"
    },
  ]

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.5.4"
  namespace        = "argocd"
  create_namespace = true
}

resource "kubectl_manifest" "argo_cd_repo_creds" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "creds-${random_integer.example.result}"
      namespace = "argocd"
      labels = {
        "argocd.argoproj.io/secret-type" = "repo-creds"
      }
    }
    type = "Opaque"
    data = {
      githubAppID             = base64encode(var.github_app_id)
      githubAppInstallationID = base64encode(var.github_app_installation_id)
      githubAppPrivateKey     = base64encode(file("${path.module}/${var.github_app_private_key_file}"))
      type                    = base64encode("git")
      url                     = base64encode("https://github.com/pauldotyu/Build26-LAB510.git")
    }
  })

  depends_on = [
    azurerm_kubernetes_cluster.example,
    helm_release.argo_cd
  ]
}

resource "kubectl_manifest" "argo_cd_app" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name       = "airunway-app-of-apps"
      namespace  = "argocd"
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/pauldotyu/Build26-LAB510.git"
        targetRevision = "HEAD"
        path           = "src/manifests/argocd/apps"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  })

  depends_on = [
    azurerm_kubernetes_cluster.example,
    helm_release.argo_cd,
    kubectl_manifest.argo_cd_repo_creds
  ]
}

resource "kubectl_manifest" "azurelustre_storageclass" {
  yaml_body = yamlencode({
    apiVersion = "storage.k8s.io/v1"
    kind       = "StorageClass"
    metadata = {
      name = "azurelustre-static"
    }
    provisioner    = "azurelustre.csi.azure.com"
    parameters     = {
      "mgs-ip-address" = azurerm_managed_lustre_file_system.example.mgs_address
    }
    reclaimPolicy    = "Retain"
    volumeBindingMode = "Immediate"
    mountOptions = [
      "noatime",
      "flock"
    ]
  })
  depends_on = [
    azurerm_kubernetes_cluster.example,
    azurerm_managed_lustre_file_system.example
  ]
}

resource "azurerm_subnet" "aks_inference" {
  name                 = "inference"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.21.3.0/24"]
}

resource "azurerm_kubernetes_cluster_node_pool" "inference" {
  name                        = "inference"
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.example.id
  vm_size                     = "Standard_NC48ads_A100_v4"
  node_count                  = 1
  min_count                   = 1
  max_count                   = 1
  auto_scaling_enabled        = true
  gpu_driver                  = "None"
  vnet_subnet_id              = azurerm_subnet.aks_inference.id
  temporary_name_for_rotation = "temp${random_integer.example.result}"

  upgrade_settings {
    drain_timeout_in_minutes      = 0
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 0
  }

  depends_on = [
    azurerm_kubernetes_cluster.example,
    helm_release.nvidia_gpu_operator,
    helm_release.istio_base,
    helm_release.istiod,
    helm_release.argo_cd,
    kubectl_manifest.argo_cd_repo_creds,
    kubectl_manifest.argo_cd_app
  ]
}

output "rg_name" {
  value = azurerm_resource_group.example.name
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.example.name
}

output "lfs_name" {
  value = azurerm_managed_lustre_file_system.example.name
}

output "lfs_mgs_address" {
  value = azurerm_managed_lustre_file_system.example.mgs_address
}