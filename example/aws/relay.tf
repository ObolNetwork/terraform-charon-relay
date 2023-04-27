module "relay-aws" {
  source                 = "git::https://github.com/ObolNetwork/terraform-charon-relay.git?ref=v0.1.1"
  relay_name             = "relay-aws"
  relay_version          = "v0.15.0"
  cluster_size           = "1"
  storageclass           = "gp2"
  base_dns               = "gcp.obol.tech"
  haproxy_replicas_count = "1"
}
