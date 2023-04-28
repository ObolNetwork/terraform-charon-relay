# Relay Deployment Guide
This Terraform example deploys a relay-1 cluster for the Obol Network on a Google Kubernetes Engine (GKE) cluster using the terraform-charon-relay module.

## Requirements
- Terraform v0.12.x or higher
- A valid domain name
- Public IP addresses for each relay node
- An operational Kubernetes cluster. In this example we use a Google Kubernetes Engine (GKE) cluster.
- Pre-installed Kubernetes add-ons: nginx-ingress, external-dns, and cert-manager.

## Usage with Google Cloud
To use this module in your Terraform configuration, follow these steps:

1. Copy the following block of code and paste it into your Terraform configuration file:

```hcl
module "relay" {
  source        = "git::git@github.com:ObolNetwork/terraform-charon-relay.git?ref=v0.1.2"
  relay_name    = "relay-1"
  relay_version = "v0.14.3"
  cluster_size  = 3
  external_ips = [
    "34.0.0.1",
    "34.0.0.2",
    "34.0.0.3",
  ]
  base_dns               = "example.com"
  haproxy_replicas_count = 3
}
```
2. Replace the external_ips values with valid public IP addresses for each relay node. The number of IP addresses must match the cluster_size.
3. Replace example.com in the base_dns field with your domain name. The relay domain will be in the format https://relay-1.yourdomain.com.
4. Adjust the cluster_size, haproxy_replicas_count, and haproxy_chart_version as needed for your setup.
5. Ensure your GKE cluster has the following Kubernetes add-ons pre-installed:
- nginx-ingress
- external-dns
- cert-manager
6. Run terraform init to initialize your Terraform workspace and download the required providers and modules.
7. Run terraform apply to deploy the relay cluster.

| Name   | Description  | Type  |  Default | Required  |
|---|---|---|---|---|
| relay_name  | The name of the relay.	  | string  |   | yes  |
| relay_version  | The version of the relay.	  | string  |	  | yes  |
| cluster_size  | The number of nodes in the cluster.	  | number  |  | yes  |
| external_ips  |	List of public IP addresses for nodes.  | list(string)	  |  | yes  |
| base_dns  | Base domain name for the relay.  | string  |   | yes  |
| haproxy_replicas_count  | The number of HAProxy replicas.	  | number  |   | yes  |

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.haproxy](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_config_map_v1.haproxy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_config_map_v1.relay](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |
| [kubernetes_ingress_v1.haproxy-external](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace_v1.relay](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_pod_disruption_budget_v1.relay](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_service_v1.relay-tcp](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_service_v1.relay-udp](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_stateful_set_v1.relay](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set_v1) | resource |
| [null_resource.backend_servers](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_base_dns"></a> [base\_dns](#input\_base\_dns) | obol base domain name | `string` | n/a | yes |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | The number of the nodes in a relay cluster | `string` | `"1"` | no |
| <a name="input_cpu_limits"></a> [cpu\_limits](#input\_cpu\_limits) | relay pod cpu limits | `string` | `null` | no |
| <a name="input_cpu_requests"></a> [cpu\_requests](#input\_cpu\_requests) | relay pod cpu requests | `string` | `"500m"` | no |
| <a name="input_external_ips"></a> [external\_ips](#input\_external\_ips) | List of public static IPs created in GCP only | `list(string)` | `null` | no |
| <a name="input_haproxy_chart_version"></a> [haproxy\_chart\_version](#input\_haproxy\_chart\_version) | Haproxy helm chart version | `string` | `"0.6.11"` | no |
| <a name="input_haproxy_replicas_count"></a> [haproxy\_replicas\_count](#input\_haproxy\_replicas\_count) | The number of haproxy replicas | `string` | `"1"` | no |
| <a name="input_loki_endpoint"></a> [loki\_endpoint](#input\_loki\_endpoint) | The loki endpoint to push logs to it. | `string` | `""` | no |
| <a name="input_memory_limits"></a> [memory\_limits](#input\_memory\_limits) | relay pod memory limits | `string` | `"1Gi"` | no |
| <a name="input_memory_requests"></a> [memory\_requests](#input\_memory\_requests) | relay pod memory requests | `string` | `"1Gi"` | no |
| <a name="input_node_selector_enabled"></a> [node\_selector\_enabled](#input\_node\_selector\_enabled) | Enable node selector | `bool` | `false` | no |
| <a name="input_relay_name"></a> [relay\_name](#input\_relay\_name) | Relay cluster name | `string` | n/a | yes |
| <a name="input_relay_version"></a> [relay\_version](#input\_relay\_version) | Charon image tag to use to deploy the relay statefulset | `string` | n/a | yes |
| <a name="input_secondary_dns"></a> [secondary\_dns](#input\_secondary\_dns) | The relay cluster secondary dns, i.e 0.relay.obol.tech | `string` | `""` | no |
| <a name="input_storageclass"></a> [storageclass](#input\_storageclass) | k8s pv storage class (standard, gp2, etc) | `string` | `"standard"` | no |
| <a name="input_udp_enabled"></a> [udp\_enabled](#input\_udp\_enabled) | Enable relay udp connectivity | `string` | `false` | no |
| <a name="input_wait_for_load_balancer"></a> [wait\_for\_load\_balancer](#input\_wait\_for\_load\_balancer) | n/a | `string` | `"true"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->