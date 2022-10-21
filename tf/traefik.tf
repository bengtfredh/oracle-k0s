resource "helm_release" "traefik" {
  depends_on = [helm_release.metallb]
  name       = "traefik"
  namespace  = "traefik"

  repository       = "https://helm.traefik.io/traefik"
  chart            = "traefik"
  create_namespace = true
  version          = "17.0.5"

  values = [<<-EOT
                 deployment:
                   replicas: 2
                   imagePullSecrets:
                     - name: dockerhub
                 podDisruptionBudget:
                   enabled: true
                   minAvailable: 1
                 providers:
                   kubernetesIngress:
                     enabled: false
                 globalArguments:
                   - "--global.checknewversion=false"
                   - "--global.sendanonymoususage=false"
                 ports:
                   web:
                     redirectTo: websecure
                   websecure:
                     tls:
                       enabled: true
                   ssh:
                     port: 2222
                     expose: true
                     exposedPort: 22
                     protocol: TCP
                 tlsOptions:
                   default:
                     minVersion: VersionTLS12
                     cipherSuites:
                       - TLS_AES_256_GCM_SHA384
                       - TLS_CHACHA20_POLY1305_SHA256
                       - TLS_AES_128_GCM_SHA256
                       - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
                       - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
                       - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
                       - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
                       - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
                       - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
                       - TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
                 tlsStore:
                   default:
                     defaultCertificate:
                       secretName: fredhs-net-cert
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

resource "kubectl_manifest" "traefik_dashboard_auth" {
  depends_on = [helm_release.traefik]
  yaml_body  = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: traefik-dashboard-auth
  namespace: traefik
type: Opaque
data:
  users: ZGFzaDokYXByMSQwakFVcXpIdiRCVjNVMXdPUWFsNVRVUVB4aDA3RnUuCgo=
YAML
}

resource "kubectl_manifest" "traefik_dashboard_middleware" {
  depends_on = [helm_release.traefik]
  yaml_body  = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: traefik-dashboard-basicauth
  namespace: traefik
spec:
  basicAuth:
    secret: traefik-dashboard-auth
YAML
}

resource "kubectl_manifest" "traefik_dashboard_ingressroute" {
  depends_on = [helm_release.traefik]
  yaml_body  = <<YAML
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
  namespace: traefik
spec:
  entryPoints:
  - websecure
  routes:
  - kind: Rule
    match: Host(`oracle-k0s-traefik.fredhs.net`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
    middlewares:
    - name: traefik-dashboard-basicauth
      namespace: traefik
    services:
    - kind: TraefikService
      name: api@internal
YAML
}