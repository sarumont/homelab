Terraform modules, Helm charts, and some docker-compose files for running my `homelab`.

This consists of several services including (but not limited to):

 - PiHole
 - Plex
 - Photoprism
 - Logitech Media Server (LMS)
 - Unifi Controller

I consider this lab a production environment, as it runs services which my family relies upon (namely, Photoprism).

Terraform modules can be found in [`tf`](./tf) and drive the majority of this setup. I run everything in a 3-node k8s cluster (Thinkcenter m900s). V1 of the lab was split into `docker-compose` and `k8s`, but with V2 I am migrating everything to `k8s` for simplicity. This is still an ongoing process.

# V1 README

Everything below was from the V1 README. I am leaving it in here while I migrate to my V2 config. Some of this will remain but most will disappear.

The configuration here is divided into three directories:

 - `k8s`
 - `docker`
 - `edge`

Services which only need to be accessed from my LAN are run via `docker-compose`. Anything that is public-facing is in a `k8s` cluster. Public access is provided via reverse proxy on a Linode server attached to my Tailscale network. Each service behind this proxy has individual login (for now, it's only Photoprism).

# Terraform Variables

This repo contains the Terraform modules. I am running `terragrunt` from the env directories (i.e. `prod/k8s`), so variables are set using `TF_VAR_foo` in a `direnv` file. In the future, I may split the modules from the configuration to add those variables to (private) source control.

# Docker Variables

    export HOST=
    export TIMEZONE=
    export PUID=
    export PGID=
    export PLEX_ADVERTISE_IP=
    export MUSIC_DIR=
    export MOVIE_DIR=
    export TV_DIR=
    export PLAYLIST_DIR=
    export PIHOLE_PASSWORD=
    export PIHOLE_IP=

# Requirements

Docker and Docker Compose.

This configuration assumes you have a `k3s` cluster deployed with the default Traefik and load balancer configuration. Your `~/.kube/config` should be configured to access this cluster.

# Routing

Routing is achieved via wildcard hostnames: `app.*`. This allows apps to live at a relative root path.

# Environment Variables

| Variable | Description |
|----------|-------------|
| `AWS_ACCESS_KEY_ID` | Used to connect to AWS S3 to store Terraform's State |
| `AWS_SECRET_ACCESS_KEY` | Used to connect to AWS S3 to store Terraform's State |

# Usage

    cd prod/k8s
    terragrunt run-all apply
    cd ../docker
    docker-compose up -d

# TODO

- [x] cert-manager / public access (via edge)
- [ ] Traefik AUTH
- [x] Plex
    - [x] Volume mounts
    - [x] Transcoding
- [x] PiHole
- [x] Photoprism
- [x] Secondary Photoprism (sister-in-law - necessary because Photoprism doesn't yet have multiple library support)
- [x] LMS
- [ ] Family dashboard
    - not sure what to do here yet...maybe a custom MagicMirror?
- [ ] Backups
    - all locally mounted volumes (anything in `~/.docker`)
    - Photoprism (docker): `docker-compose exec -T photoprism photoprism backup -i - > photoprism-db.sql`
