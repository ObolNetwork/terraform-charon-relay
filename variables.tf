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

variable "extra_domains" {
  description = "List of extra domains"
  type        = list(string)
  default     = []
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

variable "node_selector" {
  description = "Node selector"
  type        = string
  default     = null
}

variable "storageclass" {
  description = "Kubernetes storage class (standard, gp2, etc)"
  type        = string
  default     = "standard"
}

variable "memory_limits" {
  description = "Relay pod memory limits"
  type        = string
  default     = null
}

variable "memory_requests" {
  description = "Relay pod memory requests"
  type        = string
  default     = "500Mi"
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

variable "node_affinity_config" {
  description = "Deployment pod affinity configuration"
  type = list(object({
    type         = string
    weight       = number
    topology_key = string
    label_selectors = list(object({
      match_expressions = list(object({
        key      = string
        operator = string
        values   = list(string)
      }))
    }))
  }))
  default = [{
    type         = "preferred_during_scheduling_ignored_during_execution"
    weight       = 100
    topology_key = "topology.kubernetes.io/zone"
    label_selectors = [{
      match_expressions = null
    }]
  }]
}

variable "max_unavailable" {
  description = "value for PDB maxUnavailable"
  type        = string
  default     = "1"
}

variable "auto_create_tls" {
  description = "Flag to enable cert-manager annotations to auto generate tls certificates"
  type        = bool
  default     = true
}

variable "auto_create_dns" {
  description = "Flag to enable external-dns annotations to auto generate dns records"
  type        = bool
  default     = true
}
