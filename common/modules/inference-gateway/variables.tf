variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "cluster_name" {
  type        = string
  description = "Name of a target GKE cluster where the target application is deployed"
}

variable "cluster_location" {
  type        = string
  description = "Location of a target GKE cluster where the target application is deployed"
}

variable "network_name" {
  type = string
}
variable "region" {
  type = string
}

variable "create_proxy_only_subnetwork" {
  type=bool
  default = true
}

variable "proxy_only_subnetwork_name" {
  type = string
  default = "gateway-api-proxy-only"
}


variable "inference_pools" {
  type = list(object({
    name = string
    match_labels = map(string)
  }))
}

variable "inference_models" {
  type = list(object({
    name = string
    namespace = optional(string, "default")
    model_name = string
    criticality = string
    inference_pool_name = string
  }))
}

variable "gateway" {
  type= object({
    name = string
    namespace = optional(string, "default")
    gateway_class = string
  })
}

variable "http_routes" {
  type = list(object({
    name = string
    namespace = optional(string, "default")
    gateway_name = string
    inference_pool_name = string
  }))
}
