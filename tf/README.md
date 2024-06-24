Terraform modules useful for a (my) homelab.

# Modules
## base

This contains basic k8s setup including:

- MetalLB
- nginx ingress
- `cert-manager`
- NFS PVC config
- a Hello World app to test HTTP ingress
- `node-feature-discovery` (NFD)

## pihole

Pihole in k8s. DHCP is disabled in this implementation, as I am assuming that there is a router somewhere performing DHCP services (does anyone use Pihole's DHCP?).

Note that this is designed to be lights-out, but you cannot manage adlists from the config anymore. Instead, you [must use the UI](https://discourse.pi-hole.net/t/how-to-update-adlists-from-adlists-list-file/38370). I use several from [firebog.net]():

    https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt
    https://v.firebog.net/hosts/Easyprivacy.txt
    https://v.firebog.net/hosts/AdguardDNS.txt
    https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt

## intel_gpu

Module enabling detecting and allocating Intel GPUs as schedulable resources in your cluster. This is useful for hardware decoding.

## Plex

Module to deploy Plex Media Server, mounting media libraries via NFS.

# Usage

My (private) IaC repo looks something like this:

    /
      site1/
        base/
          terragrunt.hcl
        pihole/
          terragrunt.hcl
        ...
        common.hcl
        terragrunt.hcl
      site2/
        ...
    .envrc

This contains local config (IPs, etc.) and secrets (in my `.envrc` - for accessing S3 for the Terraform state).

# Notes

I started down the path of using NFS for the default `storageClass`, but that is problematic when applications use SQLite underneath. I have since settled on using local storage for the default PVCs. To prevent data loss in this scenario, I attempt to:

1. drive everything I can from the Terragrunt configuration. Since this is in a (separate) git repo, it is backed up and replicated and can easily be used to rebuild the cluster
1. optionally use NFS where SQLite isn't a factor
1. back up important things via external means (i.e. - database backups, etc.)

This allows me to use node-local storage for the pod PVCs, NFS for shared resources (i.e. Plex libraries), and avoid problems with SQLite over NFS.

In your `infra` repo, the K8s and DNSimple providers must be configured.
