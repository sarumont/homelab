# rsync_backup_lxc

Terraform module that creates a Proxmox LXC container provisioned for scheduled rsync backups via systemd timers.

## What it does

1. Generates an ed25519 SSH keypair for the container to authenticate to backup destinations
2. Creates a privileged Proxmox LXC container with NFS mount support
3. Provisions the container via SSH:
   - Installs `rsync` and `nfs-common`
   - Mounts NFS shares (added to `/etc/fstab`)
   - Writes the generated SSH private key for outbound backup connections
   - Configures SSH client (`StrictHostKeyChecking no`)
   - For each rsync job: writes a backup script, systemd service, and systemd timer
   - Writes exclude files for jobs that define `exclude_patterns`
   - Enables and starts all timers

## Usage

```hcl
module "rsync_backup" {
  source = "git::git@github.com:sarumont/homelab.git//tf/rsync_backup_lxc?ref=main"

  proxmox_node         = "node1"
  hostname             = "rsync-backup"
  ostemplate           = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
  ip_address           = "192.168.1.50/24"
  gateway              = "192.168.1.1"
  nameserver           = "192.168.1.1"
  authorized_keys_file = "/path/to/authorized_keys"
  ssh_private_key_file = "~/.ssh/id_ed25519"

  nfs_mounts = [
    {
      server      = "192.168.1.5"
      path        = "/mnt/data/photos"
      mount_point = "/mnt/photos"
    },
  ]

  rsync_jobs = [
    {
      name        = "photos-offsite"
      source      = "/mnt/photos/"
      destination = "backup-host:/backups/photos/"
      flags       = "-a --delete"
      schedule    = "*-*-* 02:00:00"
    },
    {
      name             = "music-offsite"
      source           = "/mnt/music/"
      destination      = "backup-host:/backups/music/"
      flags            = "-rt --delay-updates --chmod=D775,F664"
      schedule         = "*-*-* 03:00:00"
      exclude_patterns = ["tmp", ".cache"]
    },
  ]
}
```

## Prerequisites

Download a Debian LXC template on the target Proxmox node:

```bash
pveam update
pveam download local debian-12-standard_12.7-1_amd64.tar.zst
```

## Required providers

This module uses `proxmox`, `tls`, `null`, and `random` providers. When called via Terragrunt, generate the provider blocks in the caller.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `proxmox_node` | Target Proxmox node | `string` | — |
| `hostname` | Container hostname | `string` | — |
| `ostemplate` | LXC template path | `string` | — |
| `storage_id` | Rootfs storage | `string` | `"local-lvm"` |
| `disk_size` | Rootfs size | `string` | `"4G"` |
| `cores` | CPU cores | `number` | `1` |
| `memory` | RAM in MB | `number` | `256` |
| `ip_address` | Static IP in CIDR | `string` | — |
| `gateway` | Network gateway | `string` | — |
| `nameserver` | DNS server | `string` | — |
| `network_bridge` | Proxmox bridge | `string` | `"vmbr0"` |
| `authorized_keys_file` | Path to public keys file for root SSH access | `string` | — |
| `ssh_private_key_file` | Path to private key for Terraform provisioning | `string` | — |
| `nfs_mounts` | NFS shares to mount (`server`, `path`, `mount_point`) | `list(object)` | — |
| `rsync_jobs` | Backup job definitions (`name`, `source`, `destination`, `flags`, `schedule`, `exclude_patterns`) | `list(object)` | — |

## Outputs

| Name | Description |
|------|-------------|
| `backup_ssh_public_key` | Public key to add to backup destinations |
| `container_ip` | LXC container IP address |

## Post-apply

Add the `backup_ssh_public_key` output to `~/.ssh/authorized_keys` on each backup destination (e.g. NAS, rsync.net).

Verify inside the container:

```bash
# Check NFS mounts
df -h | grep nfs

# Check timers
systemctl list-timers

# Test a job manually
systemctl start photos-offsite.service
```
