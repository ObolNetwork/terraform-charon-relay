# terraform-charon-relay

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
| [kubernetes_ingress_v1.secondary-domain](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace_v1.relay](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace_v1) | resource |
| [kubernetes_pod_disruption_budget_v1.relay](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/pod_disruption_budget_v1) | resource |
| [kubernetes_service_v1.relay-tcp](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_service_v1.relay-udp](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |
| [kubernetes_stateful_set_v1.relay](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set_v1) | resource |
| [null_resource.backend_servers](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | Cloud provider name. The module supports aws and gcp. | `string` | n/a | yes |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | The number of the nodes in a relay cluster | `string` | n/a | yes |
| <a name="input_cpu_limits"></a> [cpu\_limits](#input\_cpu\_limits) | Relay pod cpu limits | `string` | `null` | no |
| <a name="input_cpu_requests"></a> [cpu\_requests](#input\_cpu\_requests) | Relay pod cpu requests | `string` | `"500m"` | no |
| <a name="input_external_ips"></a> [external\_ips](#input\_external\_ips) | (Optional) List of public static IPs. Only Supported by GCP. (Deprecated) | `list(string)` | `null` | no |
| <a name="input_haproxy_chart_version"></a> [haproxy\_chart\_version](#input\_haproxy\_chart\_version) | Haproxy helm chart version | `string` | `"0.6.11"` | no |
| <a name="input_haproxy_replicas_count"></a> [haproxy\_replicas\_count](#input\_haproxy\_replicas\_count) | The number of haproxy replicas | `string` | `"1"` | no |
| <a name="input_loki_endpoint"></a> [loki\_endpoint](#input\_loki\_endpoint) | (Optional) The loki endpoint to push logs to it. | `string` | `""` | no |
| <a name="input_memory_limits"></a> [memory\_limits](#input\_memory\_limits) | Relay pod memory limits | `string` | `"1Gi"` | no |
| <a name="input_memory_requests"></a> [memory\_requests](#input\_memory\_requests) | Relay pod memory requests | `string` | `"1Gi"` | no |
| <a name="input_node_selector_enabled"></a> [node\_selector\_enabled](#input\_node\_selector\_enabled) | Enable node selector | `bool` | `false` | no |
| <a name="input_primary_base_domain"></a> [primary\_base\_domain](#input\_primary\_base\_domain) | The primary base domain name to create relay subdomain. obol.tech -> relay-0.obol.tech | `string` | n/a | yes |
| <a name="input_relay_name"></a> [relay\_name](#input\_relay\_name) | Relay cluster name | `string` | n/a | yes |
| <a name="input_relay_version"></a> [relay\_version](#input\_relay\_version) | Charon image tag to use to deploy the relay statefulset | `string` | n/a | yes |
| <a name="input_secondary_base_domain"></a> [secondary\_base\_domain](#input\_secondary\_base\_domain) | (Optional) The secondary base domain name to create relay subdomain. obol.dev -> relay-0.obol.dev | `string` | `""` | no |
| <a name="input_storageclass"></a> [storageclass](#input\_storageclass) | Kubernetes storage class (standard, gp2, etc) | `string` | `"standard"` | no |
| <a name="input_udp_enabled"></a> [udp\_enabled](#input\_udp\_enabled) | Enable relay udp connectivity. (Deprecated) | `string` | `false` | no |
| <a name="input_wait_for_load_balancer"></a> [wait\_for\_load\_balancer](#input\_wait\_for\_load\_balancer) | Wait until the load balancer is created | `string` | `"true"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_lbs"></a> [aws\_lbs](#output\_aws\_lbs) | n/a |
<!-- END_TF_DOCS -->