terraform {
  backend "s3" {
    bucket                      = "terraform-state-bucket"
    region                      = "us-east-1"
    key                         = "whats-my-ip"
    endpoint                    = "http://localhost:4566"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
    dynamodb_table              = "terraform-state-table"
    dynamodb_endpoint           = "http://localhost:4566" #overriden to use localstack
    iam_endpoint                = "http://localhost:4566" #overriden to use localstack
    sts_endpoint                = "http://localhost:4566" #overriden to use localstack
  }
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
