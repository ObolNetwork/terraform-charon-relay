locals {
  aws_lbs = [for svc in kubernetes_service_v1.relay-tcp : svc.status[0].load_balancer[0].ingress[0].hostname]
  gcp_ips = var.external_ips != null ? var.external_ips : [for svc in kubernetes_service_v1.relay-tcp : svc.status[0].load_balancer[0].ingress[0].ip]
}

resource "kubernetes_namespace_v1" "relay" {
  metadata {
    name = var.relay_name
  }
}

resource "kubernetes_config_map_v1" "relay" {
  count = var.cluster_size
  metadata {
    name      = "${var.relay_name}-${count.index}"
    namespace = kubernetes_namespace_v1.relay.id
  }
  data = {
    CHARON_HTTP_ADDRESS       = "0.0.0.0:3640"
    CHARON_P2P_TCP_ADDRESS    = "0.0.0.0:3610"
    CHARON_MONITORING_ADDRESS = "0.0.0.0:3620"
    CHARON_LOG_FORMAT         = "json"
    CHARON_LOG_LEVEL          = "debug"
    CHARON_P2P_RELAY_LOGLEVEL = "debug"
    CHARON_LOKI_ADDRESSES     = var.loki_endpoint
    CHARON_LOKI_SERVICE       = var.relay_name
  }
}

resource "kubernetes_pod_disruption_budget_v1" "relay" {
  count = var.cluster_size
  metadata {
    name      = "${var.relay_name}-${count.index}"
    namespace = kubernetes_namespace_v1.relay.id
  }
  spec {
    max_unavailable = "1"
    selector {
      match_labels = {
        app = "${var.relay_name}-${count.index}"
      }
    }
  }
}

resource "kubernetes_stateful_set_v1" "relay" {
  count = var.cluster_size
  metadata {
    name      = "${var.relay_name}-${count.index}"
    namespace = kubernetes_namespace_v1.relay.id
    labels = {
      app = "${var.relay_name}-${count.index}"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${var.relay_name}-${count.index}"
      }
    }
    template {
      metadata {
        labels = {
          app = "${var.relay_name}-${count.index}"
        }
      }
      spec {
        container {
          name        = "${var.relay_name}-${count.index}"
          image       = "ghcr.io/obolnetwork/charon:${var.relay_version}"
          command     = lower(var.cloud_provider) == "gcp" ? ["sh", "-ace", "/usr/local/bin/charon relay --p2p-external-ip=${local.gcp_ips[count.index]}"] : ["sh", "-ace", "/usr/local/bin/charon relay --p2p-external-hostname=${local.aws_lbs[count.index]}"]
          working_dir = "/charon"
          env_from {
            config_map_ref {
              name = "${var.relay_name}-${count.index}"
            }
          }
          resources {
            limits = {
              cpu    = var.cpu_limits
              memory = var.memory_limits
            }

            requests = {
              cpu    = var.cpu_requests
              memory = var.memory_requests
            }
          }
          volume_mount {
            name       = "data"
            mount_path = "/charon"
          }
          liveness_probe {
            http_get {
              path = "/livez"
              port = "3640"
            }

            initial_delay_seconds = 5
            period_seconds        = 1
          }
          readiness_probe {
            http_get {
              path = "/readyz"
              port = "3640"
            }

            initial_delay_seconds = 3
            period_seconds        = 1
          }
          image_pull_policy = "Always"
        }

        affinity {
          dynamic "node_affinity_config" {
          for_each = var.node_affinity_config != {} ? [1] : []
          content { 
            node_affinity = var.node_affinity_config 
          }
        }
        }
        

        
        security_context {
          run_as_user = 0
        }
        node_selector = var.node_selector_enabled ? {
          node_pool = var.relay_name
        } : null
        toleration {
          effect = "NoSchedule"
          key    = var.relay_name
          value  = "true"
        }
        automount_service_account_token = false
        enable_service_links            = false
      }
    }
    volume_claim_template {
      metadata {
        name      = "data"
        namespace = ""
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.storageclass
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
    service_name = "${var.relay_name}-${count.index}"
  }
  depends_on = [kubernetes_namespace_v1.relay, resource.helm_release.haproxy, kubernetes_config_map_v1.relay]
}

resource "kubernetes_service_v1" "relay-tcp" {
  count = var.cluster_size
  metadata {
    name      = "${var.relay_name}-${count.index}-tcp"
    namespace = kubernetes_namespace_v1.relay.id
    annotations = lower(var.cloud_provider) == "gcp" ? {
      "cloud.google.com/neg" = "{\"ingress\":true}"
    } : null
  }
  wait_for_load_balancer = var.wait_for_load_balancer
  spec {
    port {
      name        = "p2p-tcp"
      protocol    = "TCP"
      port        = 3610
      target_port = "3610"
    }
    port {
      name        = "monitoring"
      protocol    = "TCP"
      port        = 3620
      target_port = "3620"
    }
    port {
      name        = "bootnode-http"
      protocol    = "TCP"
      port        = 3640
      target_port = "3640"
    }
    selector = {
      app = "${var.relay_name}-${count.index}"
    }
    type                    = "LoadBalancer"
    load_balancer_ip        = (lower(var.cloud_provider) == "gcp" && var.external_ips != null) ? var.external_ips[count.index] : null
    external_traffic_policy = "Local"
  }
}

resource "kubernetes_service_v1" "relay-udp" {
  count = var.udp_enabled ? var.cluster_size : 0
  metadata {
    name      = "${var.relay_name}-${count.index}-udp"
    namespace = kubernetes_namespace_v1.relay.id
    annotations = lower(var.cloud_provider) == "gcp" ? {
      "cloud.google.com/neg" = "{\"ingress\":true}"
    } : null
  }

  wait_for_load_balancer = false

  spec {
    port {
      name        = "p2p-udp"
      protocol    = "UDP"
      port        = 3630
      target_port = "3630"
    }

    selector = {
      app = "${var.relay_name}-${count.index}"
    }

    type                    = "LoadBalancer"
    load_balancer_ip        = (lower(var.cloud_provider) == "gcp" && var.external_ips != null) ? var.external_ips[count.index] : null
    external_traffic_policy = "Local"
  }
}
