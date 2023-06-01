# Charon Relay
Terraform module to deploy a charon public relay.

## Deployment Architecture
This module deploys the following infrastructure:
- HAProxy (reverse proxy), which establishes a header-base sticky session between the charon cluster nodes and the relay server
- Charon nodes run in relay mode and deployed as statefulsets

## Prerequisites
- Terraform v1.3 or higher
- A valid domain name (i.e obol.tech)
- An operational Kubernetes cluster (This module tested with GKE and EKS)
- Kubernetes cluster add-ons: nginx-ingress, external-dns, and cert-manager.

## How to use
- [`Module configuration`](MODULE.md)
- [`AWS example usage`](examples/aws/main.tf)
- [`GGP example usage`](examples/gcp/main.tf)
