resource "helm_release" "traefik" {
  name      = "traefik"
  namespace = "hub-agent"

  repository       = "https://helm.traefik.io/traefik"
  chart            = "traefik"
  create_namespace = true

  values = [<<-EOT
                 additionalArguments:
                 - --experimental.hub
                 - --hub
                 metrics:
                   prometheus:
                     addRoutersLabels: true
                 providers:
                   kubernetesIngress:
                     allowExternalNameServices: true
                 ports:
                   web: null
                   websecure: null
                   metrics:
                     expose: true
                   traefikhub-tunl:
                     port: 9901
                     expose: true
                     exposedPort: 9901
                     protocol: TCP
                 service:
                   type: ClusterIP
                 fullnameOverride: traefik-hub
            EOT
  ]

}

resource "helm_release" "traefik-hub" {
  name      = "hub-agent"
  namespace = "hub-agent"

  repository       = "https://helm.traefik.io/hub"
  chart            = "hub-agent"
  create_namespace = true

  set {
    name  = "token"
    value = "edf1d584-59e2-4a14-8388-3156ef15b355"
  }
}
