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



template "datalab" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./datawarehouse/datalab"
  data = {
    project = {
      project_id = "{{.datawarehouse_project_id}}"
      exists     = true
    }
    terraform_addons = {
        raw_config = <<EOF
        
        data "google_compute_network" "my_network" {
            name = "{{.datawarehouse_network_name}}"
            project = module.project.project_id
        }

        data "google_compute_subnetwork" "my_subnetwork" {
            name   = "{{.datawarehouseAI_subnet_name}}"
            region = "{{.datawarehouse_region}}"
            project = module.project.project_id

        }

        resource "google_project_iam_member" "datalab_instance_bq_access" {
            project = module.project.project_id
            role    = "roles/bigquery.dataEditor"
            member  = "serviceAccount:$${google_service_account.datawarehouse_ai_datalab_visualization_instance_sa.email}"
        }
        resource "google_project_iam_member" "datalab_instance_storage_access" {
            project = module.project.project_id
            role    = "roles/storage.objectAdmin"
            member  = "serviceAccount:$${google_service_account.datawarehouse_ai_datalab_visualization_instance_sa.email}"
        }
        resource "google_project_iam_member" "datalab_instance_dataflow_access" {
            project = module.project.project_id
            role    = "roles/dataflow.developer"
            member  = "serviceAccount:$${google_service_account.datawarehouse_ai_datalab_visualization_instance_sa.email}"
        }
        
        resource "google_service_account_iam_member" "cloud-users-access-to-service-account" {
            service_account_id = "$${google_service_account.datawarehouse_ai_datalab_visualization_instance_sa.name}"
            role               = "roles/iam.serviceAccountUser"
            member             = "group:{{.cloud_users_group}}"
        }
        
        module "datalab_gpu" {
            source                    = "terraform-google-modules/datalab/google//modules/gpu_instance"
            version                   = "~> 0.1"
#Code Block 2.2.4.a             
            datalab_user_email        = "{{.datawarehouseAI_datalab_user_email}}"
            project_id                = "{{.datawarehouse_project_id}}"
            #region                    = "us-west1"
            zone                      = "{{.datawarehouse_region}}-c"
            network_name              = "{{.datawarehouse_network_name}}"
            subnet_name               = data.google_compute_subnetwork.my_subnetwork.self_link
            service_account           = google_service_account.datawarehouse_ai_datalab_visualization_instance_sa.email
#Code Block 2.2.4.b            
            enable_secure_boot        = true
#Code Block 2.2.4.c            
            labels = {
                data_label = "critical"
            }
        }
    EOF
    }
    resources = {
        service_accounts = [
            {
                account_id   = "ai-datalab-instance-sa"
                resource_name = "datawarehouse_ai_datalab_visualization_instance_sa"
                description  = "Datalab Instance SA"
                display_name = "Datalab Instance SA"
            }
        ]           
            
    }
  }
}