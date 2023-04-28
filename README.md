# Relay Deployment Guide
This terraform module deploys a public relay cluster for the Obol DVT cluster

## Deployment Architecture
To deploy a DVT public relay, we use the following pieces of infrastracture:
- HAProxy as reverse proxy in front of the charon relay nodes
- The haproxy is assigned a static public IP
- The harpoxy uses cluster-name in the request header as sticky session between the charon cluster and the corresponding relay node
- 1 or more charon instances deployed in relay mode
- Each instance is assigned a public static IP

## Requirements
- Terraform v0.12.x or higher
- A valid domain name (i.e obol.tech)
- An operational Kubernetes cluster. This module is tested with both GKE and EKS
- Kubernetes add-ons: nginx-ingress, external-dns, and cert-manager.

## Usage with GCP
Please refer to examples/gcp

## Usage with AWS
Please refer to examples/aws
