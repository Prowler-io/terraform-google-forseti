/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  random_hash    = var.suffix
  server_sa_name = "forseti-server-gcp-${local.random_hash}"

  server_project_roles = [
    "roles/storage.objectViewer",
    "roles/storage.objectCreator",
    "roles/cloudsql.client",
    "roles/logging.logWriter",
    "roles/iam.serviceAccountTokenCreator",
    "roles/monitoring.metricWriter",
  ]
  server_write_roles = [
    "roles/compute.securityAdmin",
  ]
  server_read_roles = [
    "roles/appengine.appViewer",
    "roles/bigquery.metadataViewer",
    "roles/browser",
    "roles/cloudasset.viewer",
    "roles/cloudsql.viewer",
    "roles/compute.networkViewer",
    "roles/iam.securityReviewer",
    "roles/orgpolicy.policyViewer",
    "roles/servicemanagement.quotaViewer",
    "roles/serviceusage.serviceUsageConsumer",
  ]
  server_cscc_roles = [
    "roles/securitycenter.findingsEditor",
  ]

  server_cloud_profiler_roles = [
    "roles/cloudprofiler.agent",
  ]
}

#-------------------------#
# Forseti Service Account #
#-------------------------#
resource "google_service_account" "forseti_server" {
  count        = var.server_service_account == "" ? 1 : 0
  account_id   = local.server_sa_name
  project      = var.project_id
  display_name = "Forseti Server Service Account"
}

resource "google_project_iam_member" "server_roles" {
  count   = length(local.server_project_roles)
  role    = local.server_project_roles[count.index]
  project = var.project_id
  member  = var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"
}

resource "google_organization_iam_member" "org_read" {
  # Provider requires Org IAM permissions for this resource
  count  = var.perform_org_iam_config && var.org_id != "" ? length(local.server_read_roles) : 0
  role   = local.server_read_roles[count.index]
  org_id = var.org_id
  member = var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"
}
resource "local_file" "org_read" {
  count  = var.perform_org_iam_config != true && var.org_id != "" ? 1 : 0
  filename = "./files/forseti/iam_bindings_to_create/org_read"
  content  = <<-EOT
  For the Organization ${var.org_id}, these roles should be bound to ${var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"}

  ${join("\n", [ for r in local.server_read_roles : "${r}" ])}
  EOT
}

resource "google_folder_iam_member" "folder_read" {
  # Provider requires Org IAM permissions for this resource
  count  = var.perform_org_iam_config && var.folder_id != "" ? length(local.server_read_roles) : 0
  role   = local.server_read_roles[count.index]
  folder = var.folder_id
  member = var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"
}
resource "local_file" "folder_read" {
  count  = var.perform_org_iam_config != true && var.folder_id != "" ? 1 : 0
  filename = "./files/forseti/iam_bindings_to_create/folder_read"
  content  = <<-EOT
  For the Folder ${var.folder_id}, these roles should be bound to ${var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"}

  ${join("\n", [ for r in local.server_read_roles : "${r}" ])}
  EOT
}

resource "google_organization_iam_member" "org_write" {
  # Provider requires Org IAM permissions for this resource
  count  = var.perform_org_iam_config && var.org_id != "" && var.enable_write ? length(local.server_write_roles) : 0
  role   = local.server_write_roles[count.index]
  org_id = var.org_id
  member = var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"
}
resource "local_file" "org_write" {
  count  = var.perform_org_iam_config != true && var.org_id != "" && var.enable_write ? 1 : 0
  filename = "./files/forseti/iam_bindings_to_create/org_write"
  content  = <<-EOT
  For the Organization ${var.org_id}, these roles should be bound to ${var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"}

  ${join("\n", [ for r in local.server_write_roles : "${r}" ])}
  EOT
}

resource "google_folder_iam_member" "folder_write" {
  # Provider requires Org IAM permissions for this resource
  count  = var.perform_org_iam_config && var.folder_id != "" && var.enable_write ? length(local.server_write_roles) : 0
  role   = local.server_write_roles[count.index]
  folder = var.folder_id
  member = var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"
}
resource "local_file" "folder_write" {
  count  = var.perform_org_iam_config != true && var.folder_id != "" && var.enable_write ? 1 : 0
  filename = "./files/forseti/iam_bindings_to_create/folder_write"
  content  = <<-EOT
  For the Folder ${var.folder_id}, these roles should be bound to ${var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"}

  ${join("\n", [ for r in local.server_write_roles : "${r}" ])}
  EOT
}

resource "google_organization_iam_member" "org_cscc" {
  # Provider requires Org IAM permissions for this resource
  count  = var.perform_org_iam_config && var.org_id != "" && var.cscc_violations_enabled ? length(local.server_cscc_roles) : 0
  role   = local.server_cscc_roles[count.index]
  org_id = var.org_id
  member = var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"
}
resource "local_file" "org_cscc" {
  count  = var.perform_org_iam_config != true && var.org_id != "" && var.cscc_violations_enabled ? 1 : 0
  filename = "./files/forseti/iam_bindings_to_create/org_cscc"
  content  = <<-EOT
  For the Organization ${var.org_id}, these roles should be bound to ${var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"}

  ${join("\n", [ for r in local.server_cscc_roles : "${r}" ])}
  EOT
}

resource "google_organization_iam_member" "cloud_profiler" {
  # Provider requires Org IAM permissions for this resource
  count  = var.perform_org_iam_config && var.org_id != "" && var.cloud_profiler_enabled ? length(local.server_cloud_profiler_roles) : 0
  role   = local.server_cloud_profiler_roles[count.index]
  org_id = var.org_id
  member = var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"
}
resource "local_file" "cloud_profiler" {
  count  = var.perform_org_iam_config != true && var.org_id != "" && var.cloud_profiler_enabled ? 1 : 0
  filename = "./files/forseti/iam_bindings_to_create/cloud_profiler"
  content  = <<-EOT
  For the Organization ${var.org_id}, these roles should be bound to ${var.server_service_account == "" ? "serviceAccount:${google_service_account.forseti_server[0].email}" : "serviceAccount:${var.server_service_account}"}

  ${join("\n", [ for r in local.server_cloud_profiler_roles : "${r}" ])}
  EOT
}
