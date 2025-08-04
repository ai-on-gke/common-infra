resource "helm_release" "inference_pool" {
  name       = var.inference_pool_name
  repository = "oci://registry.k8s.io/gateway-api-inference-extension/charts"
  chart      = "inferencepool"
  version    = "v0.3.0"
  set = concat(
    [
      {
        name  = "provider.name"
        value = "gke"
      },
      {
        name  = "inferencePool.targetPortNumber"
        value = var.inference_pool_target_port
      }
    ],
    [
      for label_name, label_value in var.inference_pool_match_labels : {
        name  = "inferencePool.modelServers.matchLabels.${label_name}"
        value = label_value
      }
    ]
  )
}


resource "local_file" "inference_model" {
  for_each = { for model in var.inference_models : model.name => model }
  content = templatefile(
    "${path.module}/templates/inference-model.yaml.tpl",
    {
      NAME                = each.value.name
      NAMESPACE           = var.kubernetes_namespace
      MODEL_NAME          = each.value.model_name
      CRITICALITY         = each.value.criticality
      INFERENCE_POOL_NAME = var.inference_pool_name
      TARGET_MODELS       = each.value.target_models
    }
  )
  filename = "${var.rendered_templates_path}/inference-model-${each.value.name}.yaml"
}


resource "kubernetes_manifest" "inference_model" {
  for_each   = local_file.inference_model
  manifest   = provider::kubernetes::manifest_decode(each.value.content)
  depends_on = [helm_release.inference_pool]
  lifecycle {
    replace_triggered_by = [
      local_file.inference_model[each.key].content
    ]
  }
}


resource "local_file" "gateway" {
  content = templatefile(
    "${path.module}/templates/gateway.yaml.tpl",
    {
      NAME              = var.gateway_name
      NAMESPACE         = var.kubernetes_namespace
      GATEWAY_CLASS     = "gke-l7-regional-external-managed"
      MANAGED_CERT_NAME = var.tls_certificate_name
      IP_ADDRESS_NAME   = var.ip_address_name
    }
  )
  filename = "${var.rendered_templates_path}/gateway.yaml"
}

resource "kubernetes_manifest" "gateway" {
  manifest = provider::kubernetes::manifest_decode(local_file.gateway.content)
  lifecycle {
    replace_triggered_by = [
      local_file.gateway.content
    ]
  }
}


resource "local_file" "http_route" {
  content = templatefile(
    "${path.module}/templates/http-route.yaml.tpl",
    {
      NAME                = var.http_route_name
      NAMESPACE           = var.kubernetes_namespace
      GATEWAY_NAME        = var.gateway_name
      INFERENCE_POOL_NAME = var.inference_pool_name
      HOSTNAME            = var.domain
      PATH                = var.http_route_path
    }
  )
  filename = "${var.rendered_templates_path}/http-route.yaml"
}

resource "kubernetes_manifest" "http_route" {
  manifest = provider::kubernetes::manifest_decode(local_file.http_route.content)
  depends_on = [
    helm_release.inference_pool,
    kubernetes_manifest.gateway
  ]
  lifecycle {
    replace_triggered_by = [
      local_file.http_route.content
    ]
  }
}
