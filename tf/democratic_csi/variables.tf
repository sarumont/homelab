variable "democratic_csi_chart_version" {
  description = "Version of the democratic-csi Helm chart to use"
  default = "0.15.0"
}

variable "truenas_host" {
  description = "IP or hostname of the TrueNAS host"
}

variable "truenas_user" {
  description = "TrueNAS user to connect as"
  default = "root"
}

variable "truenas_password" {
  description = "TrueNAS password to use"
  sensitive = true
}

variable "truenas_private_key" {
  description = "Private key to use to connect to TrueNAS via ssh"
  sensitive = true
}

variable "iscsi_dataset" {
  description = "ZFS dataset to use for iSCSI shares. Must be 17 characters or less"
}

variable "iscsi_portal_group" {
  description = "Portal group to use for iSCSI provisioning"
  default = 1
}

variable "iscsi_initiator_group" {
  description = "Initiator group to use for iSCSI provisioning"
  default = 1
}

variable "iscsi_extent_rpm" {
  description = "Extent RPM to use for iSCSI provisioning"
  default = "7200"
}
