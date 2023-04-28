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
  description = "List of public static IPs created in GCP only"
  type        = list(string)
  default     = null
}

variable "base_dns" {
  description = "obol base domain name"
  type        = string
}

variable "udp_enabled" {
  description = "Enable relay udp connectivity"
  type        = string
  default     = false
}

variable "secondary_dns" {
  description = "The relay cluster secondary dns, i.e 0.relay.obol.tech"
  type        = string
  default     = ""
}

variable "loki_endpoint" {
  description = "The loki endpoint to push logs to it."
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
  default     = false
}

variable "storageclass" {
  description = "k8s pv storage class (standard, gp2, etc)"
  type        = string
  default     = "standard"
}

variable "memory_limits" {
  description = "relay pod memory limits"
  default     = "1Gi"
  type        = string
}

variable "memory_requests" {
  description = "relay pod memory requests"
  default     = "1Gi"
  type        = string
}

variable "cpu_limits" {
  description = "relay pod cpu limits"
  default     = null
  type        = string
}

variable "cpu_requests" {
  description = "relay pod cpu requests"
  default     = "500m"
  type        = string
}

variable "wait_for_load_balancer" {
  description = ""
  default     = "true"
  type        = string
}
