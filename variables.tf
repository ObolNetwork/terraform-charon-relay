variable "relay_name" {
  description = "Relay cluster name"
  type        = string
}

variable "cluster_size" {
  description = "The number of the nodes in a relay cluster"
  type        = string
}

variable "relay_version" {
  description = "Charon image tag to use to deploy the relay statefulset"
  type        = string
}

variable "udp_enabled" {
  description = "Enable relay udp connectivity. (Deprecated)"
  type        = string
  default     = false
}

variable "cloud_provider" {
  description = "Cloud provider name. The module supports aws and gcp."
  type        = string
}

variable "external_ips" {
  description = "(Optional) List of public static IPs. Only Supported by GCP. (Deprecated)"
  type        = list(string)
  default     = null
}

variable "primary_base_domain" {
  description = "The primary base domain name to create relay subdomain. obol.tech -> relay-0.obol.tech"
  type        = string
}

variable "secondary_base_domain" {
  description = "(Optional) The secondary base domain name to create relay subdomain. obol.dev -> relay-0.obol.dev"
  type        = string
  default     = ""
}

variable "loki_endpoint" {
  description = "(Optional) The loki endpoint to push logs to it."
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
  description = "Kubernetes storage class (standard, gp2, etc)"
  type        = string
  default     = "standard"
}

variable "memory_limits" {
  description = "Relay pod memory limits"
  type        = string
  default     = "1Gi"
}

variable "memory_requests" {
  description = "Relay pod memory requests"
  type        = string
  default     = "1Gi"
}

variable "cpu_limits" {
  description = "Relay pod cpu limits"
  type        = string
  default     = null
}

variable "cpu_requests" {
  description = "Relay pod cpu requests"
  type        = string
  default     = "500m"
}

variable "wait_for_load_balancer" {
  description = "Wait until the load balancer is created"
  type        = string
  default     = "true"
}

variable "zones" {
  description = "The list of the zones to deploy the relay cluster"
  type        = list(string)
  default     = ["eu-west-1b", "eu-west-1c"]
}