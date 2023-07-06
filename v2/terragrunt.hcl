remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "sigil-org-v2-terraform-state"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "sigil-org-v2-terraform-state-lock-table"
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        kubectl = {
          source  = "gavinbunney/kubectl"
          version = ">= 1.7.0"
        }

        mysql = {
          source = "petoju/mysql"
          version = ">= 3.0.24"
        }
      }
    }
EOF
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "helm" {
  debug = true
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "homelab"
  }
}

provider "kubectl" {
  config_path = "~/.kube/config"
  config_context = "homelab"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "homelab"
}
EOF
}
