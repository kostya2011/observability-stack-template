locals {
  namespaces = ["demo-apps", "demo-monitoring"]
}

terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_namespace" "this" {
  for_each = toset(local.namespaces)

  metadata {
    labels = {
      purpose = each.key
    }

    name = each.key
  }
}
