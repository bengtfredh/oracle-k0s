resource "helm_release" "privatebin" {
  name      = "privatebin"
  namespace = "privatebin"

  repository       = "https://privatebin.github.io/helm-chart"
  chart            = "privatebin"
  create_namespace = true

  values = [<<-EOT
                 configs:
                   conf.php: |-
                     [model]
                     class = Filesystem
                     [model_options]
                     dir = PATH "data"
                     [main]
                     fileupload = true
                     template = "bootstrap-dark"
                     syntaxhighlightingtheme = "sons-of-obsidian"
            EOT
  ]

}
