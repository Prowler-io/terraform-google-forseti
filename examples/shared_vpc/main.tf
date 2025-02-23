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

provider "google" {
  version = "~> 3.52"
}

provider "local" {
  version = "~> 1.4"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

module "forseti" {
  source                   = "../../"
  project_id               = var.project_id
  client_region            = var.region
  gsuite_admin_email       = var.gsuite_admin_email
  network                  = var.network
  subnetwork               = var.subnetwork
  network_project          = var.network_project
  org_id                   = var.org_id
  server_region            = var.region
  domain                   = var.domain
  client_instance_metadata = var.instance_metadata
  server_instance_metadata = var.instance_metadata
  client_private           = "true"
  server_private           = "true"
  forseti_version          = var.forseti_version
}
