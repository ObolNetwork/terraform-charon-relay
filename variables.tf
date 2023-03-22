variable "relay_name" {
  description = "Relay cluster name"
  type        = string
}

variable "cluster_size" {
  description = "The number of the nodes in a relay cluster"
  type        = string
  default     = "1"
}

variable "relay_version" {
  description = "Charon image tag to use to deploy the relay statefulset"
  type        = string
}

variable "external_ips" {
  description = "value"
  type        = list(string)
}

variable "base_dns" {
  description = "obol base domain name"
  type        = string
}

variable "secondary_dns" {
  description = "The relay cluster secondary dns, i.e 0.relay.obol.tech"
  type        = string
  default     = ""
}

variable "udp_enabled" {
  description = "Enable relay udp connectivity"
  type        = string
  default     = false
}

variable "loki_endpoint" {
  description = "value"
  type        = string
  default     = ""
}

variable "haproxy_chart_version" {
  description = "Haproxy helm chart version"
  type        = string
  default     = "0.6.11"
}
variable "haproxy_replicas_count" {
  description = "The number of haproxy replicas"
  type        = string
  default     = "1"
}

variable "node_selector_enabled" {
  description = "Enable node selector"
  type        = bool
  default     = true
}
