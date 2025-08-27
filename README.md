Terraform modules, Helm charts, and some docker-compose files for running my `homelab`.

This consists of several services including (but not limited to):

 - PiHole
 - Plex
 - Photoprism
 - Logitech Media Server (LMS)
 - Unifi Controller
 - Media organization:
    - Radarr
    - Sonarr

I consider this lab a production environment, as it runs services which my family relies upon (namely, Photoprism).

Terraform modules can be found in [`tf`](./tf) and drive the majority of this setup. I run everything in a 3-node k8s cluster (Thinkcenter m900s). V1 of the lab was split into `docker-compose` and `k8s`, but with V2 I am migrating everything to `k8s` for simplicity. This is still an ongoing process.

# Proxmox

Leveraging Proxmox to further simplify and automate my lab for the current iteration (v2.5?), there are a few things to do manually to set up a Proxmox host.

## Ventoy

If using Ventoy to install, the `linux` line of your grub config may capture Ventoy's ramdisk config, rendering your new Proxmox node unbootable. To resolve this, hit `e` on the Grub entry, scroll down to the `linux=` line, and remove the `rdinit=vtoy/vtoy` bit from the end of that line. Hit `C-x` to save and boot.

Once booted, you'll need to: `rm /etc/default/grub.d/installer.cfg` and run `update-grub`

## Tailscale

I have a [Tailnet](https://tailscale.com) for managing my LAN remotely, so I installed Tailscale on all my Proxmox hosts as per the instructions.

## VLAN-aware networking

If you use VLANs, make sure to enable VLAN-aware networking for your bridged interface in Proxmox:

1. Select your server.
2. Go to “Network” in the menu.
3. Select the Linux bridge (vmbro#).
4. Click “Edit” at the top of the window.
5. Check the box that says “VLAN aware”
6. Press “OK.”

## iGPU passthrough

This has been covered elsewhere, so I will leave a couple links to reference [here](https://www.michaelstinkerings.org/gpu-virtualization-with-intel-12th-gen-igpu-uhd-730/) and [here](https://github.com/Upinel/PVE-Intel-vGPU). Note the steps for installing the DKMS modules on the guests have been wrapped into my `cluster` Terraform module.

I have abandoned the above approach due to fragility and simply opted to pass
through the entire GPU. This means I have a single VM per host that has access
to the GPU, though k8s can allocate this GPU to multiple pods. This is a bit
more restrictive but also more stable, as I had issues with the fractionalized 
GPU just disappearing.

For this, you need to edit the kernel command line on your PVE host, adding the
following to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`:

```
intel_iommu=on iommu=pt
```

followed by:

```
echo i915 >> /etc/modprobe.d/blacklist.conf
update-grub
reboot
```

### Mapping

You will have to map the device as a resource to be able to use this Terraform module to deploy, as Proxmox will not allow raw PCI configuration via API. To do this, head to _Datacenter -> Resource Mappings_ in the Proxmox GUI and hit _Add_. Map your fractionalized GPUs in, giving them a name which you will refer to in your config.

![PCI resource mapping](./pci_device_mapping.png)

## VM Image

Since most of the guides ([1](https://techbythenerd.com/posts/creating-an-ubuntu-cloud-image-in-proxmox/), [2](https://www.norocketscience.at/blog/terraform/deploy-proxmox-virtual-machines-using-cloud-init)) I have been referencing use Ubuntu, I stuck with the Ubuntu Cloud images for this install. To prep a template, you must basically do this:

```sh
# install guestfs-tools
sudo apt update -y && sudo apt install libguestfs-tools -y

export VMID=9001
export TEMPLATE_NAME=ubuntu-2504-cloudinit-guesttools
export SOURCE_IMAGE=plucky-server-cloudimg-amd64.img
export DEST_IMAGE=ubuntu-plucky-puffin-2504-cloudinit-guesttools.img
export TEMPLATE_STORAGE=templates # could be local-lvm

# fetch the cloudinit image
wget https://cloud-images.ubuntu.com/plucky/current/$SOURCE_IMAGE
cp $SOURCE_IMAGE $DEST_IMAGE

# add guest tools to the template
virt-customize -a $DEST_IMAGE \
    --install qemu-guest-agent,nfs-common \
    --run-command 'systemctl enable qemu-guest-agent.service'

qm create $VMID --name "${TEMPLATE_NAME}" --memory 1024 --net0 virtio,bridge=vmbr0
qm importdisk $VMID $DEST_IMAGE $TEMPLATE_STORAGE
qm set $VMID --scsihw virtio-scsi-pci --scsi0 ${TEMPLATE_STORAGE}:${VMID}/vm-${VMID}-disk-0.raw
qm set $VMID --ide2 ${TEMPLATE_STORAGE}:cloudinit
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --serial0 socket --vga serial0
qm set $VMID --ipconfig0 ip=dhcp
qm set $VMID --agent enabled=1
qm resize $VMID scsi0 15G
qm template $VMID

# optionally clean up
rm $SOURCE_IMAGE $DEST_IMAGE
```

## iGPU DKMS module

Copy `tf/terraform-proxmox-k3s/snippets/srvio-vm-prep.yml` to `/var/lib/vz/snippets/` on your Proxmox host. You can edit the version specified in there if you like. This cloudinit configuration will install the DKMS module to enable the SRVIO iGPU passthrough.

Note that this happens asynchronously from the provisioner's perspective, so the Terraform module will apply successfully while this is still working. Depending on your node count and CPU power, this could take a few minutes (and will require a reboot). On my cluster, it takes 2-4 minutes for 3 nodes to complete this process. I could not get the DKMS module working otherwise, however, so this is the best I could do here.

## k3s

The entire purpose of this is to run k8s in the form of k3s on top. I really like [this project](https://github.com/fvumbaca/terraform-proxmox-k3s), save for two things:

1. I don't care about separating `master` and `worker` nodes in my cluster
2. I need to map the GPU and will eventually want to add multiple NICs for VLAN support on my k8s nodes

Given those constraints, I have shamelessly copied most of @fvumbaca's Terraform into this repo and modified it for my own purposes. Note I also had to bring it up-to-date with the latest version of the Proxmox TF provider.

---- 

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
