variable "authorized_keys_file" {
  description = "Path to file containing public SSH keys for remoting into nodes."
  type        = string
}

variable "network_gateway" {
  description = "IP address of the network gateway."
  type        = string
  validation {
    # condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/[0-9]{1,2}$", var.network_gateway))
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", var.network_gateway))
    error_message = "The network_gateway value must be a valid ip."
  }
}

variable "lan_subnet" {
  description = <<EOF
Subnet used by the LAN network. Note that only the bit count number at the end
is acutally used, and all other subnets provided are secondary subnets.
EOF
  type        = string
  validation {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/[0-9]{1,2}$", var.lan_subnet))
    error_message = "The lan_subnet value must be a valid cidr range."
  }
}

variable "control_plane_subnet" {
  description = <<EOF
EOF
  type        = string
  validation {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/[0-9]{1,2}$", var.control_plane_subnet))
    error_message = "The control_plane_subnet value must be a valid cidr range."
  }
}

variable "cluster_name" {
  default     = "k3s"
  type        = string
  description = "Name of the cluster used for prefixing cluster components (ie nodes)."
}

variable "node_template" {
  type        = string
  description = <<EOF
Proxmox vm to use as a base template for all nodes. Can be a template or
another vm that supports cloud-init.
EOF
}

variable "proxmox_resource_pool" {
  description = "Resource pool name to use in proxmox to better organize nodes."
  type        = string
  default     = ""
}

variable "support_node_settings" {
  type = object({
    proxmox_node   = string,
    cores          = optional(number, 2),
    sockets        = optional(number, 1),
    balloon        = optional(number, 1024),
    memory         = optional(number, 4096),
    storage_id     = optional(string, "local-lvm"),
    disk_size      = optional(string, "10G"),
    user           = optional(string, "support"),
    db_name        = optional(string, "k3s"),
    db_user        = optional(string, "k3s"),
    network_bridge = optional(string, "vmbr0"),
    network_tag    = optional(number, 0), 
  })
}

variable "node_pools" {
  description = "Node pool definitions for the cluster."
  type = list(object({
    name         = string,
    size         = number,
    proxmox_node = string,

    // subnet used for the 0th interface
    subnet = string,

    // subnets used for the nth interfaces defined in the networks object below
    // must be specified like this due to how the underlying module specifies 
    // the "ipconfigX" parameters
    subnet1 = optional(string),
    subnet2 = optional(string),
    subnet3 = optional(string),

    // bitmask of the network, not the subnet for the nodes
    bitmask1 = optional(string),
    bitmask2 = optional(string),
    bitmask3 = optional(string),

    // has to be duplicated because we cannot reference another var here
    template = string,

    taints   = optional(list(string), []),

    cores          = optional(number, 2),
    sockets        = optional(number, 1),
    balloon        = optional(number, 1024),
    memory         = optional(number, 4096),
    storage_type   = optional(string, "scsi"),
    storage_id     = optional(string, "local-lvm"),
    disk_size      = optional(string, "20G"),
    user           = optional(string, "k3s"),

    networks       = list(object({
      bridge       = optional(string, "vmbr0"),
      tag          = optional(number, 0),
    }))

    // list of PCI ID mappings to use for these VMs
    pci_mappings   = optional(list(object({
      mapping_id   = string,
      pcie         = optional(bool, true)
      primary_gpu  = optional(bool, false)
      rombar       = optional(bool, true)
    })), [])

    use_srvio      = optional(bool, false)
  }))
}

variable "api_hostnames" {
  description = "Alternative hostnames for the API server."
  type        = list(string)
  default     = []
}

variable "k3s_disable_components" {
  description = "List of components to disable. Ref: https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/#kubernetes-components"
  type        = list(string)
  default     = []
}

variable "http_proxy" {
  default     = ""
  type        = string
  description = "http_proxy"
}

variable "nameserver" {
  default     = ""
  type        = string
  description = "nameserver"
}
