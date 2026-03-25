locals {
  container_ip = split("/", var.ip_address)[0]

  backup_configs = [
    for job in var.rsync_jobs : {
      name         = job.name
      has_excludes = length(job.exclude_patterns) > 0
      script_b64 = base64encode(templatefile("${path.module}/templates/backup.sh.tftpl", {
        name             = job.name
        source           = job.source
        destination      = job.destination
        flags            = job.flags
        exclude_patterns = job.exclude_patterns
        push_url         = job.push_url
      }))
      service_b64 = base64encode(templatefile("${path.module}/templates/backup.service.tftpl", {
        name = job.name
      }))
      timer_b64 = base64encode(templatefile("${path.module}/templates/backup.timer.tftpl", {
        name     = job.name
        schedule = job.schedule
      }))
      excludes_b64 = length(job.exclude_patterns) > 0 ? base64encode(join("\n", job.exclude_patterns)) : ""
    }
  ]
}

resource "tls_private_key" "backup_ssh" {
  algorithm = "ED25519"
}

resource "random_password" "root" {
  length  = 16
  special = false
}

resource "proxmox_lxc" "backup" {
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

resource "null_resource" "apparmor_unconfined" {
  depends_on = [proxmox_lxc.backup]

  triggers = {
    lxc_id = proxmox_lxc.backup.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      TICKET=$(curl -sk -d "username=${var.proxmox_user}" --data-urlencode "password=${var.proxmox_password}" \
        "${var.proxmox_api_url}/access/ticket")
      TOKEN=$(echo "$TICKET" | jq -r '.data.ticket')
      CSRF=$(echo "$TICKET" | jq -r '.data.CSRFPreventionToken')
      # Enable NFS mount support
      curl -sk -X PUT \
        -H "Cookie: PVEAuthCookie=$TOKEN" \
        -H "CSRFPreventionToken: $CSRF" \
        -d "features=mount%3Dnfs" \
        "${var.proxmox_api_url}/nodes/${var.proxmox_node}/lxc/${proxmox_lxc.backup.vmid}/config"
      # Reboot to apply
      curl -sk -X POST \
        -H "Cookie: PVEAuthCookie=$TOKEN" \
        -H "CSRFPreventionToken: $CSRF" \
        "${var.proxmox_api_url}/nodes/${var.proxmox_node}/lxc/${proxmox_lxc.backup.vmid}/status/reboot"
      sleep 10
    EOT
  }
}

resource "null_resource" "provision" {
  depends_on = [null_resource.apparmor_unconfined]

  triggers = {
    lxc_id = proxmox_lxc.backup.id
  }

  connection {
    type        = "ssh"
    user        = "root"
    host        = local.container_ip
    agent = true
  }

  provisioner "file" {
    destination = "/tmp/setup.sh"
    content = templatefile("${path.module}/templates/setup.sh.tftpl", {
      timezone               = var.timezone
      nfs_mounts             = var.nfs_mounts
      static_routes          = var.static_routes
      backup_configs         = local.backup_configs
      backup_ssh_private_key = tls_private_key.backup_ssh.private_key_openssh
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
