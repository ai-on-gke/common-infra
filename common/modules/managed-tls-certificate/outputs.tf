output "dns_authorize_record_data" {
  value = google_certificate_manager_dns_authorization.instance.dns_resource_record[0].data
}
output "dns_authorize_record_name" {
  value = google_certificate_manager_dns_authorization.instance.dns_resource_record[0].name
}
