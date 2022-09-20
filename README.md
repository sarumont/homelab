Terraform modules and Terragrunt config for my `homelab`. This consists of the following services:

 - PiHole
 - Plex
 - Photoprism
 - LMS

I consider this lab a production environment, as it runs services which my family relies upon (namely, Photoprism).

# Requirements

This configuration assumes you have a `k3s` cluster deployed with the default Traefik and load balancer configuration. Your `~/.kube/config` should be configured to access this cluster.

# Routing

Routing is achieved via wildcard hostnames: `app.*`. This allows apps to live at a relative root, which is imperitive for certain apps (i.e. Plex) to function.

# Environment Variables

| Variable | Description |
|----------|-------------|
| `AWS_ACCESS_KEY_ID` | Used to connect to AWS S3 to store Terraform's State |
| `AWS_SECRET_ACCESS_KEY` | Used to connect to AWS S3 to store Terraform's State |
