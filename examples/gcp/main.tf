module "relay-1" {
  source                 = "git::https://github.com/ObolNetwork/terraform-charon-relay.git?ref=v0.1.2"
  relay_name             = "relay-1"
  relay_version          = "v0.14.3"
  cluster_size           = 3
  cloud_provider         = "gcp"
  primary_base_domain    = "example.com" # the relay domain: https://relay-1.example.com
  haproxy_replicas_count = 3
}
