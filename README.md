# Charon Relay
Terraform module to deploy a charon public relay.

## Prerequisites
- Terraform v1.3+
- An operational Kubernetes GKE or EKS cluster with these add-ons, nginx-ingress, external-dns, and cert-manager
- A valid public domain name (i.e obol.tech)

## Deployment Architecture
- HAProxy, to establish a header-base sticky session between the charon DV nodes and the relay server
- Charon nodes, running in relay mode and deployed as statefulsets

## How to use
- [`Module configuration`](MODULE.md)
- [`AWS example usage`](examples/aws/main.tf)
- [`GGP example usage`](examples/gcp/main.tf)
