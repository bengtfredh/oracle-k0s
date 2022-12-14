resource "helm_release" "kubernetes-dashboard" {
  name = "kubernetes-dashboard"

  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  namespace        = "kubernetes-dashboard"
  create_namespace = true

  values = [<<-EOT
                 metricsScraper:
                   enabled: true
                 extraManifests:
                   - apiVersion: v1
                     kind: ServiceAccount
                     metadata:
                       name: admin-user
                       namespace: kubernetes-dashboard
                   - apiVersion: rbac.authorization.k8s.io/v1
                     kind: ClusterRoleBinding
                     metadata:
                       name: admin-user
                     roleRef:
                       apiGroup: rbac.authorization.k8s.io
                       kind: ClusterRole
                       name: cluster-admin
                     subjects:
                     - kind: ServiceAccount
                       name: admin-user
                       namespace: kubernetes-dashboard
                   - apiVersion: v1
                     kind: Secret
                     metadata:
                       name: admin-user-token
                       namespace: kubernetes-dashboard
                       annotations:
                         kubernetes.io/service-account.name: admin-user
                     type: kubernetes.io/service-account-token
                 extraArgs:
                   - --enable-insecure-login
                 protocolHttp: true
                 service:
                   externalPort: 80
            EOT
  ]

}
