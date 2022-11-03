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
