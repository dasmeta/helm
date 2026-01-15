resource "helm_release" "this" {
  name = "basic"
  ## for remote chart use this instead local chart
  # repository = "https://dasmeta.github.io/helm"
  # chart     = "base"
  # version    = "0.3.14"
  chart = "${path.module}/../../../charts/base/" # /charts/base/

  namespace = "localhost"
  wait      = true

  values = [file("${path.module}/../basic.yaml")] # /examples/base/basic.yaml
}
