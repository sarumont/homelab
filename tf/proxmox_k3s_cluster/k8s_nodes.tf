locals {
  listed_cluster_nodes = flatten([
    for pool in var.node_pools :
    [
      for i in range(pool.size) :
      merge(pool, {
        i  = i
        ip = cidrhost(pool.subnet, i)
        subnet1 = pool.subnet1 == null ? null : {
          ip = cidrhost(pool.subnet1, i)
          bits = pool.bitmask1
        }
        subnet2 = pool.subnet2 == null ? null : {
          ip = cidrhost(pool.subnet2, i)
          bits = pool.bitmask2
        }
        subnet3 = pool.subnet3 == null ? null : {
          ip = cidrhost(pool.subnet3, i)
          bits = pool.bitmask3
        }
      })
    ]
  ])

  node_ips = [for node in local.listed_cluster_nodes : node.ip]

  mapped_cluster_nodes = {
    for node in local.listed_cluster_nodes : "${node.name}-${node.i}" => node
  }
}

resource "random_password" "k3s-server-token" {
  length           = 32
  special          = false
  override_special = "_%@"
}

resource "proxmox_vm_qemu" "k3s-node" {
  depends_on = [
    proxmox_vm_qemu.k3s-support,
  ]

  for_each = local.mapped_cluster_nodes

  target_node = each.value.proxmox_node
  name        = "${var.cluster_name}-${each.key}"

  clone = each.value.template

  pool = var.proxmox_resource_pool

  machine = "q35"  # required for PCI mapping
  bios    = "ovmf" # required for DKMS modules for SRVIO
  cores   = each.value.cores
  sockets = each.value.sockets
  balloon = each.value.balloon
  memory  = each.value.memory
  onboot  = true
  automatic_reboot = true

  boot    = "order=scsi0" # has to be the same as the OS disk of the template
  scsihw  = "virtio-scsi-single"

  agent = 1
  serial {
    id = 0
  }
  efidisk {
    efitype = "4m"
    storage = each.value.storage_id
  }
  disks {
    scsi {
      scsi0 {
        disk {
          storage = each.value.storage_id
          size    = each.value.disk_size
        }
      }
    }
    ide {
      ide1 {
        cloudinit {
          storage = each.value.cloudinit_storage_id
        }
      }
    }
  }

  dynamic "pci" {
    for_each = each.value.pci_mappings
    content { 
      id = pci.key
      mapping_id = pci.value.mapping_id
      pcie = pci.value.pcie
      primary_gpu = pci.value.primary_gpu
      rombar = pci.value.rombar
    }
  }

  dynamic "network" {
    for_each = each.value.networks
    content { 
      id        = network.key
      bridge    = network.value.bridge
      firewall  = true
      link_down = false
      model     = "virtio"
      queues    = 0
      rate      = 0
      tag       = network.value.tag
    }
  }

  # cloudinit
  os_type    = "cloud-init"
  cicustom   = each.value.use_srvio ? "vendor=local:snippets/srvio-vm-prep.yml" : "" # /var/lib/vz/snippets/srvio-vm-prep.yml
  ciuser     = each.value.user
  ciupgrade  = each.value.ciupgrade
  ipconfig0  = "ip=${each.value.ip}/${local.lan_subnet_cidr_bitnum},gw=${var.network_gateway}"
  ipconfig1  = each.value.subnet1 == null ? null : "ip=${each.value.subnet1.ip}/${each.value.subnet1.bits}"
  ipconfig2  = each.value.subnet2 == null ? null : "ip=${each.value.subnet2.ip}/${each.value.subnet2.bits}"
  ipconfig3  = each.value.subnet3 == null ? null : "ip=${each.value.subnet3.ip}/${each.value.subnet3.bits}"
  sshkeys    = file(var.authorized_keys_file)
  nameserver = var.nameserver

  connection {
    type    = "ssh"
    user    = each.value.user
    host    = each.value.ip
  }

  provisioner "remote-exec" {
    inline = [
      templatefile("${path.module}/scripts/install-k3s-server.sh.tftpl", {
        mode         = "server"
        tokens       = [random_password.k3s-server-token.result]
        alt_names    = concat([local.support_node_ip], var.api_hostnames)
        server_hosts = []
        node_taints  = each.value.taints
        disable      = var.k3s_disable_components
        datastores = [{
          host     = "${local.support_node_ip}:3306"
          name     = "k3s"
          user     = "k3s"
          password = random_password.k3s-master-db-password.result
        }]
        http_proxy  = var.http_proxy
      })
    ]
  }

  provisioner "remote-exec" {
    inline = [
      templatefile("${path.module}/scripts/install-iscsi-support.sh.tftpl", {})
    ]
  }

  provisioner "remote-exec" {
    inline = [
      templatefile("${path.module}/scripts/install-intel-gpu-support.sh.tftpl", {
        pci_mappings = each.value.pci_mappings
      })
    ]
  }

  # always reboot for good measure - 'automatic_reboot' above doesn't seem to do the trick
  provisioner "remote-exec" {
    inline = [
      "sudo shutdown -r 5"
    ]
  }
}

data "external" "kubeconfig" {
  depends_on = [
    proxmox_vm_qemu.k3s-support,
    proxmox_vm_qemu.k3s-node,
  ]

  program = [
    "/usr/bin/ssh",
    "-o UserKnownHostsFile=/dev/null",
    "-o StrictHostKeyChecking=no",
    "${local.listed_cluster_nodes[0].user}@${local.listed_cluster_nodes[0].ip}",
    "echo '{\"kubeconfig\":\"'$(sudo cat /etc/rancher/k3s/k3s.yaml | base64)'\"}'"
  ]
}
