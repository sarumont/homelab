terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/plex/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}

resource "helm_release" "plex" {
  name       = "plex"
  repository = "https://charts.saturnwire.com"
  chart      = "plex"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
<<EOT
replicaCount: ${var.replica_count}
image:
  tag: ${var.plex_image_tag}
EOT
  ]
}
