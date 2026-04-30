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

  cpu {
    cores = var.cores
  }
  memory  = var.memory
  machine = var.machine != "" ? var.machine : null
  bios    = var.bios
  start_at_node_boot = true
  scsihw  = "virtio-scsi-single"
  boot    = "order=scsi0"
  agent   = 1
  serial {
    id = 0
  }

  efidisk {
    efitype = "4m"
    storage = var.efi_storage_id != "" ? var.efi_storage_id : var.storage_id
  }

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
      tag      = network.value.tag > 0 ? network.value.tag : null
    }
  }

  dynamic "pci" {
    for_each = { for i, d in var.pci_devices : i => d }
    content {
      id          = pci.key
      mapping_id  = pci.value.mapping_id
      raw_id      = pci.value.raw_id
      pcie        = pci.value.pcie
      rombar      = pci.value.rombar
      primary_gpu = pci.value.primary_gpu
    }
  }

  dynamic "usb" {
    for_each = { for i, d in var.usb_devices : i => d }
    content {
      id         = usb.key
      device_id  = usb.value.device_id
      mapping_id = usb.value.mapping_id
      usb3       = usb.value.usb3
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
      timezone           = var.timezone
      nfs_mounts         = var.nfs_mounts
      directories        = var.directories
      sysctl_settings    = var.sysctl_settings
      install_intel_gpu  = var.install_intel_gpu
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
      timezone           = var.timezone
      nfs_mounts         = var.nfs_mounts
      directories        = var.directories
      sysctl_settings    = var.sysctl_settings
      install_intel_gpu  = var.install_intel_gpu
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

  # Reboot after provisioning to load any new kernel/firmware (e.g. Intel GPU drivers)
  provisioner "remote-exec" {
    inline = ["sudo shutdown -r +1 || true"]
  }
}
