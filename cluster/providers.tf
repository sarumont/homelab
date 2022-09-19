terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.6"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
  }
}

provider "helm" {
  kubernetes {
    config_context = var.kubernetes_context
    config_path = var.kubernetes_config
  }
}

provider "kubernetes" {
  config_context = var.kubernetes_context
  config_path = var.kubernetes_config
}
