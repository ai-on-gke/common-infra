resource "google_certificate_manager_certificate" "default" {
  project  = var.project_id
  name     = var.certificate_name
  location = var.location
  managed {
    domains = [
      google_certificate_manager_dns_authorization.instance.domain,
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.instance.id,
    ]
  }
}


resource "google_certificate_manager_dns_authorization" "instance" {
  project  = var.project_id
  name     = "${var.certificate_name}-dns-auth"
  location = var.location
  domain   = var.domain
}
