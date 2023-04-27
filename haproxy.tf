resource "helm_release" "haproxy" {
  name       = "haproxy"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "haproxy"
  version    = var.haproxy_chart_version
  namespace  = var.relay_name
  values     = local.values
  depends_on = [kubernetes_namespace_v1.relay, kubernetes_config_map_v1.haproxy]
}

resource "kubernetes_config_map_v1" "haproxy" {
  metadata {
    name      = "haproxy"
    namespace = kubernetes_namespace_v1.relay.id
    annotations = {
      "meta.helm.sh/release-name"      = "haproxy"
      "meta.helm.sh/release-namespace" = var.relay_name
    }
    labels = {
      "app.kubernetes.io/component"  = "haproxy"
      "app.kubernetes.io/instance"   = "haproxy"
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/name"       = "haproxy"
    }
  }

  data = {
    "haproxy.cfg" = <<EOF
global
  log stdout format raw local0
  maxconn 1024
defaults
  log global
  timeout client 60s
  timeout connect 60s
  timeout server 60s
frontend fe_main
  bind :8080
  default_backend relays
backend relays
  mode http
  balance hdr(Charon-Cluster)
${local.servers_config}
    EOF
  }
}

locals {
  servers_config = trim(join("", formatlist("%s \n", null_resource.backend_servers[*].triggers.server)), ",")

  values = [
    <<EOF
---
service:
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: http
  type: ClusterIP
  externalTrafficPolicy: Local
replicaCount: ${var.haproxy_replicas_count}
containerPorts:
  - name: http
    containerPort: 8080
  - name: bootnode-http
    containerPort: 3640
existingConfigmap: haproxy
ingress:
  enabled: true
  hostname: ${var.relay_name}.${var.base_dns}
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt"
    nginx.ingress.kubernetes.io/app-root: /enr
    cert-manager.io/issue-temporary-certificate: "true"
    acme.cert-manager.io/http01-edit-in-place: "true"
  tls: true
  ingressClassName: nginx
EOF
  ]
}

resource "null_resource" "backend_servers" {
  count = var.cluster_size
  triggers = {
    server = var.external_ips != null ? "  server ${var.relay_name}-${count.index} ${var.external_ips[count.index]}:3640 check  inter 10s  fall 12  rise 2" : "  server ${var.relay_name}-${count.index} ${kubernetes_service_v1.relay-tcp[count.index].status[0].load_balancer[0].ingress[0].hostname}:3640 check  inter 10s  fall 12  rise 2"
  }
}

# secondary ingress to handle traffic from the `relay.obol.tech domains`
resource "kubernetes_ingress_v1" "haproxy-external" {
  count = var.secondary_dns != "" ? 1 : 0
  metadata {
    name      = "haproxy-external"
    namespace = var.relay_name

    labels = {
      "app.kubernetes.io/instance" = "haproxy-external"
      "app.kubernetes.io/name"     = "haproxy-external"
    }

    annotations = {
      "cert-manager.io/cluster-issuer"                 = "letsencrypt"
      "nginx.ingress.kubernetes.io/app-root"           = "/enr"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "cert-manager.io/issue-temporary-certificate"    = "true"
      "acme.cert-manager.io/http01-edit-in-place"      = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.secondary_dns]
      secret_name = "${var.secondary_dns}-tls"
    }

    rule {
      host = var.secondary_dns

      http {
        path {
          path      = "/"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = "haproxy"

              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}
