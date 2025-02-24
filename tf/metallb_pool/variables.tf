variable "name" {
  description = "The name of the LB pool to create"
}

variable "namespace" {
  description = "The namespace to use for the pool resources"
  default = "metallb"
}

variable "lb_pool" {
  description = "IP address Pool to use for load balancer"
}

variable "autoassign" {
  description = "True to allow MetalLB to auto-assign from this LB pool"
  default = false
}
