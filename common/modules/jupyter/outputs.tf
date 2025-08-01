# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

output "jupyterhub_uri" {
  value = var.add_auth ? module.iap_auth[0].domain : ""
}

output "jupyterhub_user" {
  value = var.add_auth ? "" : "admin"
}

output "jupyterhub_password" {
  value     = var.add_auth ? "" : random_password.generated_password[0].result
  sensitive = true
}
output "jupyterhub_ip_address" {
  value = var.add_auth ? module.iap_auth[0].ip_address : ""
}
