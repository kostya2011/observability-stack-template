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

provider "random" {}
