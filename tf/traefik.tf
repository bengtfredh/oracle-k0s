resource "helm_release" "traefik" {
  name = "traefik"

  repository       = "https://helm.traefik.io/traefik"
  chart            = "traefik"
  namespace        = "hub-agent"
  create_namespace = true

  set {
    name  = "hub.enabled"
    value = "true"
  }

  set {
    name  = "ports.web"
    value = "null"
  }

  set {
    name  = "ports.websecure"
    value = "null"
  }

  set {
    name  = "ports.metrics.expose"
    value = "true"
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "fullnameOverride"
    value = "traefik-hub"
  }

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
