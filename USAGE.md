# Relay Deployment Guide
This Terraform example deploys a relay-1 cluster for the Obol Network on a Google Kubernetes Engine (GKE) cluster using the terraform-charon-relay module.

## Requirements
- Terraform v0.12.x or higher
- A valid domain name
- Public IP addresses for each relay node
- An operational Kubernetes cluster. In this example we use a Google Kubernetes Engine (GKE) cluster.
- Pre-installed Kubernetes add-ons: nginx-ingress, external-dns, and cert-manager.

## Usage
To use this module in your Terraform configuration, follow these steps:

1. Copy the following block of code and paste it into your Terraform configuration file:

```hcl
module "relay-1" {
  source        = "git::git@github.com:ObolNetwork/terraform-charon-relay.git?ref=v0.1.0"
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
