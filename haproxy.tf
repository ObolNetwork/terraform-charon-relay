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

  cert_manager_annotations = var.auto_create_tls ? [
    "cert-manager.io/cluster-issuer: \"letsencrypt\"",
    "cert-manager.io/issue-temporary-certificate: \"true\"",
    "acme.cert-manager.io/http01-edit-in-place: \"true\""
  ] : []
  cert_manager_annotations_yaml = join("\n", local.cert_manager_annotations)

  tls_yaml = join("", [
    for domain in concat(var.extra_domains) : <<EOT
  - hosts:
    - ${domain}
    secretName: ${replace(domain, ".", "-")}-tls
EOT
  ])

  extra_domains_yaml = length(var.extra_domains) > 0 ? join("", [
    for host in var.extra_domains : <<EOT
    - name: "${host}"
      path: /
EOT
  ]) : ""

  dns_annotations_yaml = var.auto_create_dns ? "" : "external-dns.alpha.kubernetes.io/hostname: \"\""

  node_selector_yaml = var.node_selector_enabled ? join("\n", [
    "nodeSelector:",
    "  \"node_pool\": \"${var.node_selector}\"",
    "tolerations:",
    "  - key: \"${var.node_selector}\"",
    "    operator: \"Equal\"",
    "    value: \"true\"",
    "    effect: \"NoSchedule\""
  ]) : ""

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
  ingressClassName: nginx
  hostname: ${var.relay_name}.${var.primary_base_domain}
  annotations:
    ${indent(4, local.cert_manager_annotations_yaml)}
    ${indent(4, local.dns_annotations_yaml)}
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
${length(var.extra_domains) > 0 ? "  extraHosts:" : ""}
${local.extra_domains_yaml}
  tls: true
${length(var.extra_domains) > 0 ? "  extraTls:" : ""}
${local.tls_yaml}
${local.node_selector_yaml}
EOF
  ]
}

resource "null_resource" "backend_servers" {
  count = var.cluster_size
  triggers = {
    server = lower(var.cloud_provider) == "gcp" ? "  server ${var.relay_name}-${count.index} ${local.gcp_ips[count.index]}:3640 check  inter 10s  fall 12  rise 2" : "  server ${var.relay_name}-${count.index} ${local.aws_lbs[count.index]}:3640 check  inter 10s  fall 12  rise 2"
  }
}
