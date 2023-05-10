# Charon Relay
Terraform module to deploy a charon public relay.

## Deployment Architecture
This module deploys the following infrastructure:
- HAProxy (reverse proxy) in front of the charon relay nodes
- The haproxy uses the `cluster-name` to establish a sticky session between the charon cluster nodes and the relay server
- One or more charon instances started in relay mode and deployed as Kubernetes statefulsets.

## Prerequisites
- Terraform v1.3 or higher
- A valid domain name (i.e obol.tech)
- An operational Kubernetes cluster (GKE and EKS are only supported)
- Kubernetes add-ons: nginx-ingress, external-dns, and cert-manager.

## How to use
Please refer to the examples directory for AWS and GCP use cases.
