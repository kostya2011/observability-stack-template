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
  namespaces = ["demo-apps", "demo-monitoring"]
  helm_releases_tmpl = {
    monitoring = {
      enabled         = var.monitoring_helm_enabled
      chart           = "./monitoring-helm"
      namespace       = "demo-monitoring"
      atomic          = true
      cleanup_on_fail = true
      values = [
        file("./monitoring-helm/values.yaml")
      ]
    }
    echo-server = {
      enabled         = var.echo_nginx_server_helm_enabled
      repository      = "https://ealenn.github.io/charts"
      chart           = "echo-server"
      version         = "0.5.0"
      atomic          = true
      cleanup_on_fail = true
      namespace       = "demo-apps"
    }
    python-demo-logs-app = {
      enabled         = var.py_logging_helm_enabled
      chart           = "./demo-services/python-app/deployment"
      namespace       = "demo-monitoring"
      atomic          = true
      cleanup_on_fail = true
      values = [
        file("./demo-services/python-app/deployment/values.yaml")
      ]
    }
  }
  helm_releases = { for k, v in local.helm_releases_tmpl : k => v if v.enabled == true }
}
