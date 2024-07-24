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
  log stdout format rfc3164 local0
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
  hostname: ${var.relay_name}.${var.primary_base_domain}
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt"
    nginx.ingress.kubernetes.io/app-root: /enr
    cert-manager.io/issue-temporary-certificate: "true"
    acme.cert-manager.io/http01-edit-in-place: "true"
    nginx.org/server-snippets: |
      location ~* ^/(?!enr$|enr/|$) {
        return 403;
      }
    nginx.ingress.kubernetes.io/configuration-snippet: |
      location ~* ^/(?!enr$|enr/|$) {
        return 403;
      }
  tls: true
  ingressClassName: nginx
EOF
  ]
}

resource "null_resource" "backend_servers" {
  count = var.cluster_size
  triggers = {
    server = lower(var.cloud_provider) == "gcp" ? "  server ${var.relay_name}-${count.index} ${local.gcp_ips[count.index]}:3640 check  inter 10s  fall 12  rise 2" : "  server ${var.relay_name}-${count.index} ${local.aws_lbs[count.index]}:3640 check  inter 10s  fall 12  rise 2"
  }
}

# an ingress to handle traffic from the secondary relay domain
resource "kubernetes_ingress_v1" "secondary-domain" {
  count = var.secondary_base_domain != "" ? 1 : 0
  metadata {
    name      = "secondary-domain"
    namespace = var.relay_name

    labels = {
      "app.kubernetes.io/instance" = "secondary-domain"
      "app.kubernetes.io/name"     = "secondary-domain"
    }

    annotations = {
      "cert-manager.io/cluster-issuer"                    = "letsencrypt"
      "nginx.ingress.kubernetes.io/app-root"              = "/enr"
      "nginx.ingress.kubernetes.io/force-ssl-redirect"    = "true"
      "cert-manager.io/issue-temporary-certificate"       = "true"
      "acme.cert-manager.io/http01-edit-in-place"         = "true"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOT
      location ~* ^/(?!enr$|enr/|$) {
        return 403;
      }
      EOT
      "nginx.org/server-snippets"                         = <<-EOT
      location ~* ^/(?!enr$|enr/|$) {
        return 403;
      }
      EOT
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.secondary_base_domain]
      secret_name = "${var.secondary_base_domain}-tls"
    }

    rule {
      host = var.secondary_base_domain

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
