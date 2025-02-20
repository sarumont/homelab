locals {
  support_node_ip = cidrhost(var.control_plane_subnet, 0)
}

locals {
  lan_subnet_cidr_bitnum = split("/", var.lan_subnet)[1]
}

resource "proxmox_pool" "k3s-resource-pool" {
  poolid = var.proxmox_resource_pool
  comment = "Resource pool for k3s cluster. Managed by Terraform"
}

resource "proxmox_vm_qemu" "k3s-support" {
  depends_on = [
    proxmox_pool.k3s-resource-pool,
  ]
  target_node = var.proxmox_node
  name        = join("-", [var.cluster_name, "support"])

  clone = var.node_template

  pool = var.proxmox_resource_pool

  cores   = var.support_node_settings.cores
  sockets = var.support_node_settings.sockets
  memory  = var.support_node_settings.memory
  onboot  = true

  boot    = "order=scsi0" # has to be the same as the OS disk of the template
  scsihw  = "virtio-scsi-single"

  agent = 1
  serial {
    id = 0
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.support_node_settings.storage_id
          size    = var.support_node_settings.disk_size
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = var.support_node_settings.storage_id
        }
      }
    }
  }

  network {
    id        = 0
    bridge    = var.support_node_settings.network_bridge
    firewall  = true
    link_down = false
    model     = "virtio"
    queues    = 0
    rate      = 0
    tag       = var.support_node_settings.network_tag
  }

  # cloudinit
  os_type = "cloud-init"
  ciuser = var.support_node_settings.user
  ciupgrade = false
  ipconfig0 = "ip=${local.support_node_ip}/${local.lan_subnet_cidr_bitnum},gw=${var.network_gateway}"
  sshkeys = file(var.authorized_keys_file)
  nameserver = var.nameserver

  connection {
    type = "ssh"
    user = var.support_node_settings.user
    host = local.support_node_ip
  }

  provisioner "file" {
    destination = "/tmp/mariadb.sources"
    content = templatefile("${path.module}/config/mariadb.sources.tftpl", { })
  }

  provisioner "file" {
    destination = "/tmp/install.sh"
    content = templatefile("${path.module}/scripts/install-support-apps.sh.tftpl", {
      root_password = random_password.support-db-password.result

      k3s_database = var.support_node_settings.db_name
      k3s_user     = var.support_node_settings.db_user
      k3s_password = random_password.k3s-master-db-password.result
      
      http_proxy  = var.http_proxy
    })
  }
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/install.sh",
      "/tmp/install.sh",
      "rm -r /tmp/install.sh",
    ]
  }
}

resource "random_password" "support-db-password" {
  length           = 16
  special          = false
  override_special = "_%@"
}

resource "random_password" "k3s-master-db-password" {
  length           = 16
  special          = false
  override_special = "_%@"
}

resource "null_resource" "k3s_nginx_config" {

  depends_on = [
    proxmox_vm_qemu.k3s-support
  ]

  triggers = {
    config_change = filemd5("${path.module}/config/nginx.conf.tftpl")
  }

  connection {
    type = "ssh"
    user = var.support_node_settings.user
    host = local.support_node_ip
  }

  provisioner "file" {
    destination = "/tmp/nginx.conf"
    content = templatefile("${path.module}/config/nginx.conf.tftpl", {
      k3s_server_hosts = [for ip in local.node_ips :
        "${ip}:6443"
      ]
      k3s_nodes = local.node_ips
    })
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo systemctl restart nginx.service",
    ]
  }
}
