Terraform modules and Terragrunt config for my `homelab`. This consists of the following services:

 - PiHole
 - Plex
 - Photoprism
 - LMS

I consider this lab a production environment, as it runs services which my family relies upon (namely, Photoprism).

# Terraform Variables

This repo contains the Terraform modules. I am running `terragrunt` from the env directories (i.e. `prod/`), so variables are set using `TF_VAR_foo` in a `direnv` file. In the future, I may split the modules from the configuration to add those variables to (private) source control.

# Requirements

This configuration assumes you have a `k3s` cluster deployed with the default Traefik and load balancer configuration. Your `~/.kube/config` should be configured to access this cluster.

# Routing

Routing is achieved via wildcard hostnames: `app.*`. This allows apps to live at a relative root, which is imperitive for certain apps (i.e. Plex) to function.

# Environment Variables

| Variable | Description |
|----------|-------------|
| `AWS_ACCESS_KEY_ID` | Used to connect to AWS S3 to store Terraform's State |
| `AWS_SECRET_ACCESS_KEY` | Used to connect to AWS S3 to store Terraform's State |

# Usage

    cd prod/
    terragrunt run-all apply

# TODO

- [ ] cert-manager / public access
    - Everything will need password protection. Alternatively, I can add Auth/Autz at the Traefik layer
- [x] Plex
    - [ ] Volume mounts (blocked, waiting for NAS)
    - [ ] Transcoding (blocked, waiting for NAS)
- [ ] PiHole
- [ ] Photoprism
- [ ] LMS
- [ ] Family dashboard
    - not sure what to do here yet...maybe a custom MagicMirror?
- [ ] Backups
