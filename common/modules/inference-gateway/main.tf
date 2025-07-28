resource "google_compute_subnetwork" "proxy-only" {
  count = var.create_proxy_only_subnetwork == true? 1: 0
  project= var.project_id
  name                    = var.proxy_only_subnetwork_name
  region                  = var.region
  network                 = var.network_name
  purpose = "REGIONAL_MANAGED_PROXY"
  role = "ACTIVE"
  ip_cidr_range = "10.127.0.0/23"
}


resource "helm_release" "inference_pool" {
  for_each = {for pool in var.inference_pools: pool.name => pool}
  provider = helm.cluster
  name             = each.value.name
  repository       = "oci://registry.k8s.io/gateway-api-inference-extension/charts"
  chart = "inferencepool"
  version = "v0.3.0"
  set = concat(
    [
      {
        name="provider.name"
        value="gke"
      },
      {
        name="inferencePool.targetPortNumber"
        value=8000
      }
    ],
    [
      for label_name, label_value in each.value.match_labels: { 
        name = "inferencePool.modelServers.matchLabels.${label_name}"
        value = label_value
      }
    ]
  )
}


resource "local_file" "inference_model" {
  for_each = {for model in var.inference_models: model.name => model}
  content = templatefile(
    "${path.module}/templates/inference-model.yaml.tpl",
    {
      NAME = each.value.name
      NAMESPACE = each.value.namespace
      MODEL_NAME = each.value.model_name
      CRITICALITY = each.value.criticality
      INFERENCE_POOL_NAME = each.value.inference_pool_name 
    }
  )
  filename = "${path.module}/gen/inference-model-${each.value.name}.yaml"
}



resource "kubernetes_manifest" "inference_model" {
  provider = kubernetes.cluster
  for_each = local_file.inference_model
  manifest =  provider::kubernetes::manifest_decode(each.value.content)
  depends_on = [helm_release.inference_pool]
}


resource "local_file" "gateway" {
  content = templatefile(
    "${path.module}/templates/gateway.yaml.tpl",
    {
      NAME = var.gateway.name
      NAMESPACE = var.gateway.namespace
      GATEWAY_CLASS = var.gateway.gateway_class
    }
  )
  filename = "${path.module}/gen/gateway.yaml"
}

resource "kubernetes_manifest" "gateway" {
  provider = kubernetes.cluster
  manifest =  provider::kubernetes::manifest_decode(local_file.gateway.content)
  depends_on = [
    google_compute_subnetwork.proxy-only,
    kubernetes_manifest.inference_model
  ]
}


resource "local_file" "http_route" {
  for_each = { for route in var.http_routes: route.name => route}
  content = templatefile(
    "${path.module}/templates/http-route.yaml.tpl",
    {
      NAME = each.value.name
      NAMESPACE = each.value.namespace
      GATEWAY_NAME = each.value.gateway_name
      INFERENCE_POOL_NAME = each.value.inference_pool_name
    }
  )
  filename = "${path.module}/gen/http-route-${each.value.name}.yaml"
}

resource "kubernetes_manifest" "http_route" {
  for_each = local_file.http_route
  provider = kubernetes.cluster
  manifest =  provider::kubernetes::manifest_decode(each.value.content)
  depends_on = [
    helm_release.inference_pool,
    kubernetes_manifest.gateway
  ]
}
