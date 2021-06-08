# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#******************************  Template code starts from here ******************************

data = {
  parent_type     = "{{.parent_type}}"
  parent_id       = "{{.parent_id}}"
  billing_account = "{{.billing_account}}"
  state_bucket    = "{{.terraform_state_storage_bucket}}"
  
  # Default locations for resources. Can be overridden in individual templates.
  bigquery_location   = "{{.datawarehouse_region}}"
  storage_location    = "{{.datawarehouse_region}}"
  compute_region = "{{.datawarehouse_region}}"
  compute_zone = "a"
  labels = {
    env = "prod"
  }
}

# Resource deployment can be further splitted to group resources and share resource templates.



template "app-engine" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./datawarehouse/appengine"
  data = {
    project = {
      project_id = "{{.datawarehouse_project_id}}"
      exists     = true
    }
    terraform_addons = {
        raw_config = <<EOF

#Code Block 2.2.3.a
        resource "google_project_iam_binding" "app_engine_access" {
            project = module.project.project_id
            role    = "roles/appengine.appCreator"

            members = [
                "group:{{.cloud_users_group}}",
            ]
        }
        resource "google_app_engine_domain_mapping" "domain_mapping" {
            domain_name = "{{.appengine_mapping_domain_name}}"  # "assuredworkload.dev"
            project = module.project.project_id
#Code Block 2.2.3.b
            ssl_settings {
                ssl_management_type = "AUTOMATIC"
            }
        }

        
    EOF
    }
    resources = {

        bigquery_datasets =   [
                 {
                resource_name               = "datawarehouse_gtm_appengine_data_storage_bq_dataset_name"
                dataset_id                  = "{{.datawarehouse_gtm_appengine_data_storage_bq_dataset_name}}"
#Code Block 2.2.2.c
                labels = {
                    data_type = "gtm-container-data"
                    data_criticality = "high"
                }
#Code Block 2.2.2.a
                access = [
                {
                    role          = "roles/bigquery.dataOwner"
                    special_group = "projectOwners"
                },
                {
                    role           = "roles/bigquery.dataViewer"
                    group_by_email = "{{.cloud_users_group}}"
                },
                ]
            }
        ]  
            
    }
  }
}