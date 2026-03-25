locals {
  # First NIC IP (without CIDR) used for SSH connection
  primary_ip = split("/", var.networks[0].ip)[0]
  subnet_bits = split("/", var.networks[0].ip)[1]

  # Build ipconfig0..ipconfig3 from networks list
  ipconfigs = {
    for i, net in var.networks : "ipconfig${i}" =>
      net.gateway != "" ? "ip=${net.ip},gw=${net.gateway}" : "ip=${net.ip}"
  }
}

resource "proxmox_vm_qemu" "vm" {
  target_node = var.proxmox_node
  name        = var.hostname

  clone = var.template

  cores   = var.cores
  memory  = var.memory
  onboot  = true
  scsihw  = "virtio-scsi-single"
  boot    = "order=scsi0"
  agent   = 1

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.storage_id
          size    = var.disk_size
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = var.cloudinit_storage_id
        }
      }
    }
  }

  dynamic "network" {
    for_each = { for i, net in var.networks : i => net }
    content {
      id       = network.key
      bridge   = network.value.bridge
      firewall = true
      model    = "virtio"
      tag      = network.value.tag > 0 ? network.value.tag : -1
    }
  }

  # cloud-init
  os_type    = "cloud-init"
  ciuser     = var.user
  ipconfig0  = lookup(local.ipconfigs, "ipconfig0", null)
  ipconfig1  = lookup(local.ipconfigs, "ipconfig1", null)
  ipconfig2  = lookup(local.ipconfigs, "ipconfig2", null)
  ipconfig3  = lookup(local.ipconfigs, "ipconfig3", null)
  sshkeys    = file(var.authorized_keys_file)
  nameserver = var.nameserver
}

resource "null_resource" "provision" {
  depends_on = [proxmox_vm_qemu.vm]

  triggers = {
    vm_id            = proxmox_vm_qemu.vm.id
    compose_sha      = sha256(var.docker_compose_content)
    env_sha          = sha256(jsonencode(var.env_vars))
    setup_sha = sha256(templatefile("${path.module}/templates/setup.sh.tftpl", {
      timezone        = var.timezone
      nfs_mounts      = var.nfs_mounts
      directories     = var.directories
      sysctl_settings = var.sysctl_settings
    }))
  }

  connection {
    type = "ssh"
    user = var.user
    host = local.primary_ip
  }

  # 1. Push and run setup script
  provisioner "file" {
    destination = "/tmp/setup.sh"
    content = templatefile("${path.module}/templates/setup.sh.tftpl", {
      timezone        = var.timezone
      nfs_mounts      = var.nfs_mounts
      directories     = var.directories
      sysctl_settings = var.sysctl_settings
    })
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
      "rm /tmp/setup.sh",
    ]
  }

  # 2. Push docker-compose.yml
  provisioner "file" {
    destination = "/tmp/docker-compose.yml"
    content     = var.docker_compose_content
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/docker-compose.yml /opt/docker/docker-compose.yml",
    ]
  }

  # 3. Push .env (even if empty, to clear stale vars)
  provisioner "file" {
    destination = "/tmp/docker.env"
    content     = join("\n", [for k, v in var.env_vars : "${k}=${v}"])
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/docker.env /opt/docker/.env",
      "sudo chmod 600 /opt/docker/.env",
      "cd /opt/docker && sudo docker compose up -d --remove-orphans",
    ]
  }
}
