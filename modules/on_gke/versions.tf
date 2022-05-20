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


terraform {
  required_version = ">= 0.15"
  required_providers {
    google = {
      source  = "hashicorp/google"
      configuration_aliases = [ google.forseti, google.network ]
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      configuration_aliases = [ google-beta.forseti ]
    }
    helm = {
      source  = "hashicorp/helm"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    null = {
      source  = "hashicorp/null"
    }
    random = {
      source  = "hashicorp/random"
    }
    template = {
      source  = "hashicorp/template"
    }
    tls = {
      source  = "hashicorp/tls"
    }
  }
}
