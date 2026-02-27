terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_namespace" "gitops_app" {
  metadata {
    name = "gitops-app"
    labels = {
      managed-by  = "terraform"
      environment = "dev"
      project     = "gitops-monitoring"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      managed-by  = "terraform"
      environment = "dev"
      project     = "gitops-monitoring"
    }
  }
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "gitops-app-config"
    namespace = "gitops-app"
    labels = {
      managed-by = "terraform"
      app        = "gitops-app"
    }
  }

  data = {
    APP_ENV         = "development"
    METRICS_ENABLED = "true"
    LOG_LEVEL       = "info"
  }
}
