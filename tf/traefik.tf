resource "helm_release" "traefik" {
  #depends_on = [helm_release.metallb]
  name       = "traefik"
  namespace  = "traefik"

  repository       = "https://helm.traefik.io/traefik"
  chart            = "traefik"
  create_namespace = true
  version          = var.traefik_version

  values = [<<-EOT
                 hub:
                   enabled: true
                 deployment:
                   replicas: 3
                 podDisruptionBudget:
                   enabled: true
                   minAvailable: 1
                 providers:
                   kubernetesIngress:
                     enabled: false
                 service:
                   type: ClusterIP
                 affinity:
                   podAntiAffinity:
                     preferredDuringSchedulingIgnoredDuringExecution:
                     - weight: 100
                       podAffinityTerm:
                         labelSelector:
                           matchExpressions:
                           - key: app.kubernetes.io/name
                             operator: In
                             values:
                             - traefik
                         topologyKey: topology.kubernetes.io/hostname
            EOT
  ]

}

resource "helm_release" "traefik_hub" {
  name = "hub-agent"

  repository       = "https://helm.traefik.io/hub"
  chart            = "hub-agent"
  namespace        = "hub-agent"
  create_namespace = true

  set {
    name  = "token"
    value = var.traefik_hub_token
  }

}
