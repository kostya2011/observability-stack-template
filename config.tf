terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

locals {
  kube_config = {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
  namespaces = ["demo-echo-server", "demo-python-app", "demo-monitoring", "demo-loki"]
  helm_releases_tmpl = {
    monitoring = {
      enabled         = var.monitoring_helm_enabled
      chart           = "./monitoring-helm"
      namespace       = "demo-monitoring"
      atomic          = false
      cleanup_on_fail = false
      values = [
        file("./monitoring-helm/values.yaml")
      ]
    }
    echo-server = {
      enabled         = var.echo_nginx_server_helm_enabled
      repository      = "https://ealenn.github.io/charts"
      chart           = "echo-server"
      version         = "0.5.0"
      atomic          = false
      cleanup_on_fail = true
      namespace       = "demo-echo-server"
    }
    python-demo-logs-app = {
      enabled         = var.py_logging_helm_enabled
      chart           = "./demo-services/python-app/deployment"
      atomic          = false
      cleanup_on_fail = true
      namespace       = "demo-python-app"
      override_values = {
        "pdb.maxUnavailable" = "1"
        "gh_packages_token"  = var.py_logging_gh_token
      }
    }
    loki = {
      enabled         = var.loki_helm_enabled
      repository      = "https://grafana.github.io/helm-charts"
      chart           = "loki"
      version         = "6.5.0"
      atomic          = false
      cleanup_on_fail = false
      namespace       = "demo-loki"
      values = [
        templatefile("./logging/values-loki.tfpl",
          {
            minio_enabled  = true
            minio_replicas = 1
            minio_size_gb  = 2
        })
      ]
    }
    promtail = {
      enabled         = var.loki_helm_enabled
      repository      = "https://grafana.github.io/helm-charts"
      chart           = "promtail"
      version         = "6.15.5"
      atomic          = false
      cleanup_on_fail = false
      namespace       = "demo-loki"
      values = [
        templatefile("./logging/values-promtail.tfpl", {})
      ]
    }
  }
  helm_releases = { for k, v in local.helm_releases_tmpl : k => v if v.enabled == true }
}
