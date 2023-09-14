variable "operator_chart_version" {
  description = "Version of the Intel Device Plugin Operator Helm chart to use"
  default = "0.27.1"
}

variable "device_plugins_chart_version" {
  description = "Version of the Intel GPU Helm chart to use"
  default = "0.27.1"
}

variable "shared_device_number" {
  description = "Number of times each GPU can be shared"
  default = "1"
}
