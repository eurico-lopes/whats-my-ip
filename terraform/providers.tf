terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    shell = {
      source  = "scottwinkler/shell"
      version = "1.7.10"
    }
  }
}