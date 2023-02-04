terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.16"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.4.3"
    }
  }
}
