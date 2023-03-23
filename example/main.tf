module "relay-1" {
  source        = "git::https://github.com/ObolNetwork/terraform-charon-relay.git?ref=v0.1.0"
  relay_name    = "relay-1"
  relay_version = "v0.14.3"
  cluster_size  = 3
  external_ips = [
    # number of external ips must match the number of the relay nodes (clsuter_size)
    # replace the below ips with valid public ips
    "34.0.0.1",
    "34.0.0.2",
    "34.0.0.3",
  ]
  base_dns               = "example.com" # the relay domain: https://relay-1.example.com
  haproxy_replicas_count = 3
}
