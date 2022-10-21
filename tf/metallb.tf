resource "helm_release" "metallb" {
  name = "metallb"

  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  namespace        = "metallb-system"
  create_namespace = true
  version          = "0.13.6"

  reset_values = true
  force_update = true
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
  - 10.0.255.55-10.0.255.66
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
  nodeSelectors:
  - matchLabels:
      kubernetes.io/hostname: k0s-worker1
  - matchLabels:
      kubernetes.io/hostname: k0s-worker2
YAML
}
