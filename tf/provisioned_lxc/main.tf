locals {
  container_ip = split("/", var.ip_address)[0]
}

resource "random_password" "root" {
  length  = 16
  special = false
}

resource "proxmox_lxc" "container" {
  target_node  = var.proxmox_node
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  password     = random_password.root.result
  unprivileged = false
  start        = true
  onboot       = true

  cores  = var.cores
  memory = var.memory

  rootfs {
    storage = var.storage_id
    size    = var.disk_size
  }

  network {
    name   = "eth0"
    bridge = var.network_bridge
    ip     = var.ip_address
    gw     = var.gateway
  }

  nameserver      = var.nameserver
  ssh_public_keys = file(var.authorized_keys_file)
}

resource "null_resource" "nfs_feature_flag" {
  count      = length(var.nfs_mounts) > 0 ? 1 : 0
  depends_on = [proxmox_lxc.container]

  triggers = {
    lxc_id = proxmox_lxc.container.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      TICKET=$(curl -sk -d "username=${var.proxmox_user}" --data-urlencode "password=${var.proxmox_password}" \
        "${var.proxmox_api_url}/access/ticket")
      TOKEN=$(echo "$TICKET" | jq -r '.data.ticket')
      CSRF=$(echo "$TICKET" | jq -r '.data.CSRFPreventionToken')
      curl -sk -X PUT \
        -H "Cookie: PVEAuthCookie=$TOKEN" \
        -H "CSRFPreventionToken: $CSRF" \
        -d "features=mount%3Dnfs" \
        "${var.proxmox_api_url}/nodes/${var.proxmox_node}/lxc/${proxmox_lxc.container.vmid}/config"
      curl -sk -X POST \
        -H "Cookie: PVEAuthCookie=$TOKEN" \
        -H "CSRFPreventionToken: $CSRF" \
        "${var.proxmox_api_url}/nodes/${var.proxmox_node}/lxc/${proxmox_lxc.container.vmid}/status/reboot"
      sleep 10
    EOT
  }
}

resource "null_resource" "provision" {
  depends_on = [proxmox_lxc.container, null_resource.nfs_feature_flag]

  triggers = {
    lxc_id    = proxmox_lxc.container.id
    setup_sha = sha256(var.setup_script)
  }

  connection {
    type  = "ssh"
    user  = "root"
    host  = local.container_ip
    agent = true
  }

  provisioner "file" {
    destination = "/tmp/setup.sh"
    content = templatefile("${path.module}/templates/setup.sh.tftpl", {
      timezone     = var.timezone
      nfs_mounts   = var.nfs_mounts
      setup_script = var.setup_script
    })
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh",
      "rm /tmp/setup.sh",
    ]
  }
}
