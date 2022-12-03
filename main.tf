locals {
  kube_config = {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
  namespaces = ["demo-apps", "demo-monitoring"]
  helm_releases = {
    monitoring = {
      chart     = "./monitoring-helm"
      namespace = "demo-monitoring"
      atomic    = true
      values = [
        file("./monitoring-helm/values.yaml")
      ]
    }
  }
}

terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "kubernetes" {
  config_path    = local.kube_config.config_path
  config_context = local.kube_config.config_context
}

provider "helm" {
  kubernetes {
    config_path    = local.kube_config.config_path
    config_context = local.kube_config.config_context
  }
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

# Helm releases
resource "helm_release" "this" {
  for_each = local.helm_releases

  name       = each.key
  repository = try(each.value.repository, null)
  chart      = each.value.chart
  version    = try(each.value.version, null)

  values    = try(each.value.values, null)
  namespace = try(each.value.namespace, "default")
  verify    = try(each.value.verify, false)
  atomic    = try(each.value.atomic, false)

  dynamic "set" {
    for_each = try(each.value.override_values, {})
    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }

  depends_on = [
    kubernetes_namespace.this
  ]
}
