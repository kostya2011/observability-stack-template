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
  helm_releases = {
    monitoring = {
      chart           = "./monitoring-helm"
      namespace       = "demo-monitoring"
      atomic          = true
      cleanup_on_fail = true
      values = [
        file("./monitoring-helm/values.yaml")
      ]
    }
    echo-server = {
      repository      = "https://ealenn.github.io/charts"
      chart           = "echo-server"
      version         = "0.5.0"
      atomic          = true
      cleanup_on_fail = true
      namespace       = "demo-apps"
    }
    python-demo-logs-app = {
      chart           = "./demo-services/python-logs/deployment"
      namespace       = "demo-monitoring"
      atomic          = true
      cleanup_on_fail = true
      values = [
        file("./demo-services/python-logs/deployment/values.yaml")
      ]
    }
  }
}


