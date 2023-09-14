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

Note that this is designed to be lights-out, but you cannot manage adlists from the config anymore. Instead, you [must use the UI](https://discourse.pi-hole.net/t/how-to-update-adlists-from-adlists-list-file/38370)

## intel_gpu

Module enabling detecting and allocating Intel GPUs as schedulable resources in your cluster. This is useful for hardware decoding.

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
