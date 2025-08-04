variable "project_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_location" {
  type = string
}

variable "rendered_templates_path" {
  type = string
}

variable "kubernetes_namespace" {
  type = string
}

variable "gateway_name" {
  type = string
}

variable "ip_address_name" {
  type = string
}

variable "domain" {
  type    = string
  default = ""
}


variable "tls_certificate_name" {
  type    = string
  default = ""
}

variable "inference_pool_name" {
  type = string
}

variable "inference_pool_match_labels" {
  type = map(string)
}

variable "inference_pool_target_port" {
  type = number
}

variable "inference_models" {
  type = list(object({
    name        = string
    model_name  = string
    criticality = string
    target_models = optional(
      list(object({
        name   = string
        weight = number
      })),
      []
    )
  }))
}

variable "http_route_name" {
  type = string
}

variable "http_route_path" {
  type = string
}
