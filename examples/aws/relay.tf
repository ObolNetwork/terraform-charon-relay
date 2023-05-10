module "relay-1" {
  source                 = "git::https://github.com/ObolNetwork/terraform-charon-relay.git?ref=v0.1.2"
  relay_name             = "relay-aws"
  relay_version          = "v0.15.0"
  cluster_size           = "1"
  storageclass           = "gp2"
  cloud_provider         = "aws"
  primary_base_domain    = "example.com" # the relay domain: https://relay-1.example.com
  haproxy_replicas_count = "1"
}
