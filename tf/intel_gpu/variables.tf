variable "operator_chart_version" {
  description = "Version of the Intel Device Plugin Operator Helm chart to use"
  default = "0.32.0"
}

variable "device_plugins_chart_version" {
  description = "Version of the Intel GPU Helm chart to use"
  default = "0.32.0"
}

variable "shared_device_number" {
  description = "Number of times each GPU can be shared"
  default = "1"
}

variable "enable_monitoring" {
  description = "True to enable monitoring"
  default = true
}
