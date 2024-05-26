# Helm releases
resource "helm_release" "this" {
  for_each = local.helm_releases

  name       = each.key
  repository = try(each.value.repository, null)
  chart      = each.value.chart
  version    = try(each.value.version, null)

  values            = try(each.value.values, null)
  namespace         = try(each.value.namespace, "default")
  verify            = try(each.value.verify, false)
  atomic            = try(each.value.atomic, false)
  cleanup_on_fail   = try(each.value.cleanup_on_fail, false)
  create_namespace  = try(each.value.create_namespace, true)
  dependency_update = true

  dynamic "set" {
    for_each = try(each.value.override_values, {})
    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }
}
