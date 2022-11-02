resource "helm_release" "metallb" {
  name = "metallb"

  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  namespace        = "metallb-system"
  create_namespace = true
  version          = var.metallb_version

}

resource "kubectl_manifest" "metallb_ipadresspool" {
  depends_on = [helm_release.metallb]
  yaml_body  = <<YAML
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: metallb-ipadresspool
  namespace: metallb-system
spec:
  addresses:
  - 10.234.235.8/30
YAML
}

resource "kubectl_manifest" "metallb_l2advertisement" {
  depends_on = [kubectl_manifest.metallb_ipadresspool]
  yaml_body  = <<YAML
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: metallb-l2advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - metallb-ipadresspool
YAML
}
