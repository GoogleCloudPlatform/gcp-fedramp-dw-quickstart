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

template "datawarehouse" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./datawarehouse/network"
  data = {
    project = {
      project_id = "{{.datawarehouse_project_id}}"
      exists     = true
      apis = [
            "compute.googleapis.com",
            "iam.googleapis.com",
            "cloudkms.googleapis.com",
            "bigquery.googleapis.com",
            "bigqueryconnection.googleapis.com",
            "bigquerydatatransfer.googleapis.com",
            "bigqueryreservation.googleapis.com",
            "bigquerystorage.googleapis.com",
            "dns.googleapis.com",
            "servicenetworking.googleapis.com",
            "container.googleapis.com",
            "pubsub.googleapis.com",
            "dataflow.googleapis.com",
			"logging.googleapis.com",
            "monitoring.googleapis.com",
            "dlp.googleapis.com",
            "ml.googleapis.com",
            "aiplatform.googleapis.com",
            "notebooks.googleapis.com",
            "mlkit.googleapis.com",
            "language.googleapis.com",
            "documentai.googleapis.com",
            "appengine.googleapis.com",
            "appengineflex.googleapis.com"

      ]
    }
    terraform_addons = {
        raw_config = <<EOF

        provider "google" {
            project     = "{{.datawarehouse_project_id}}"
            region      = "{{.datawarehouse_region}}"
        }
        
        provider "google-beta" {
            project     = "{{.datawarehouse_project_id}}"
            region      = "{{.datawarehouse_region}}"
        }
        
        # This firewall rule helps Dataflow worker VMs communicate with each other
        resource "google_compute_firewall" "datawarehouse_dataflow_workers_internal_communication_firewall" {
            name    = "datawarehouse-dataflow-workers-internal-communication-firewall"
            network = "{{.datawarehouse_network_name}}"
            project = module.project.project_id
            depends_on = [ module.datawarehouse_dataflow_network, module.cloud_sql_private_service_access_datawarehouse_dataflow_network]
            allow {
                protocol = "icmp"
            }

            allow {
                protocol = "tcp"
                ports    = ["12345-12346"]
            }
            source_ranges = [
                "{{.datawarehouse_subnet_ip_range}}"
            ]
            target_tags = ["dataflow"]
        }
        

    EOF
    }
    resources = {
        
        compute_networks =  [{
            
            name = "{{.datawarehouse_network_name}}" 
            resource_name = "datawarehouse_dataflow_network"
            # Enabling private Service access
            cloud_sql_private_service_access = {}
            subnets = [
                {
                name="{{.datawarehouse_subnet_name}}"
                compute_region="{{.datawarehouse_region}}"   
                ip_range="{{.datawarehouse_subnet_ip_range}}"  

                },
                {
                name="{{.datawarehouseAI_subnet_name}}"
                compute_region="{{.datawarehouse_region}}"   
                ip_range="{{.datawarehouseAI_subnet_ip_range}}"  
                },
            ]   
        }]
    }
  }
}

template "logging" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./logging/network"
  data = {
    project = {
      project_id = "{{.logging_project_id}}"
      exists     = true
      apis = [
            "compute.googleapis.com",
            "iam.googleapis.com",
            "servicenetworking.googleapis.com",
			"logging.googleapis.com",
            "stackdriver.googleapis.com",
            "bigquery.googleapis.com",
            "bigqueryconnection.googleapis.com",
            "bigquerydatatransfer.googleapis.com",
            "bigqueryreservation.googleapis.com",
            "bigquerystorage.googleapis.com",
            "pubsub.googleapis.com",
            "dataflow.googleapis.com",
            "dlp.googleapis.com",
      ]
    }
    terraform_addons = {
        raw_config = <<EOF

        provider "google" {
            project     = "{{.logging_project_id}}"
            region      = "{{.logging_project_region}}"
        }
        
        provider "google-beta" {
            project     = "{{.logging_project_id}}"
            region      = "{{.logging_project_region}}"
        }
        
        # This firewall rule helps Dataflow worker VMs communicate with each other
        resource "google_compute_firewall" "dataflow_workers_internal_communication_firewall" {
            name    = "dataflow-workers-internal-communication-firewall"
            network = "{{.dataflow_network_name}}"
            project = module.project.project_id
            depends_on = [ module.logging_network, module.cloud_sql_private_service_access_logging_network]
            allow {
                protocol = "icmp"
            }

            allow {
                protocol = "tcp"
                ports    = ["12345-12346"]
            }
            source_ranges = [
                "{{.dataflow_subnet_ip_range}}"
            ]
            target_tags = ["dataflow"]
        }


    EOF
    }
    resources = {
        # Network used by Dataflow workers
        compute_networks =  [{
            
            name = "{{.dataflow_network_name}}" 
            resource_name = "logging_network"
            # Enabling private Service access
            cloud_sql_private_service_access = {}
            subnets = [
                {
                name="{{.dataflow_subnet_name}}"
                compute_region="{{.logging_project_region}}"   
                ip_range="{{.dataflow_subnet_ip_range}}"  
                }
            ]   
        }]
    }
  }
}