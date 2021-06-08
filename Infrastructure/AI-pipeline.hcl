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

template "ai-pipeline" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./datawarehouse/AI-pipeline"
  data = {
    project = {
      project_id = "{{.datawarehouse_project_id}}"
      exists     = true
      apis = [
			"monitoring.googleapis.com",
            
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

        data "google_project" "project_number" {
			project_id  = module.project.project_id
		}
        
        data "google_service_account" "bq_to_gcs_sa" {
            account_id = "dataflow-job-bq-to-gcs-tf-sa"
            project    = module.project.project_id
        }

        data "google_compute_network" "my_network" {
            name = "{{.datawarehouse_network_name}}"
            project = module.project.project_id
        }

        data "google_compute_subnetwork" "my_subnetwork" {
            name   = "{{.datawarehouseAI_subnet_name}}"
            region = "{{.datawarehouse_region}}"
        }
#Code Block 2.2.6.a 
        # Users having service account user role can connect to notebook instance via proxy.
        resource "google_service_account_iam_member" "cloud-users-access-to-service-account" {
            service_account_id = "$${google_service_account.datawarehouse_ai_notebook_deeplearning_instance_sa.name}"
            role               = "roles/iam.serviceAccountUser"
            member             = "group:{{.cloud_users_group}}"
        }
#Code Block 2.2.8.a
        resource "google_project_iam_binding" "ml_access" {
            project = module.project.project_id
            role    = "roles/ml.developer"

            members = [
                "group:{{.cloud_users_group}}",
                "serviceAccount:$${google_service_account.datawarehouse_ai_notebook_deeplearning_instance_sa.email}"
            ]
        }
        resource "google_project_iam_binding" "notebook_instance_bq_access" {
            project = module.project.project_id
            role    = "roles/bigquery.dataEditor"

            members = [
                "serviceAccount:$${google_service_account.datawarehouse_ai_notebook_deeplearning_instance_sa.email}",
            ]
        }
        resource "google_project_iam_binding" "notebook_instance_cloud_storage_access" {
            project = module.project.project_id
            role    = "roles/storage.objectAdmin"

            members = [
                "serviceAccount:$${google_service_account.datawarehouse_ai_notebook_deeplearning_instance_sa.email}",
            ]
        }
#Code Block 2.2.5.a
        resource "google_project_iam_binding" "dataflow_access" {
            project = module.project.project_id
            role    = "roles/dataflow.developer"

            members = [
                "group:{{.cloud_users_group}}",
                "serviceAccount:$${google_service_account.datawarehouse_ai_notebook_deeplearning_instance_sa.email}",
            ]
        }
       
        
        resource "google_notebooks_instance" "instance" {
            name = "{{.datawarehouseAI_notebooks_instance_name}}"
            location = "{{.datawarehouse_region}}-b"
            # Machine type can be customized
            machine_type = "n1-standard-2"
            network = data.google_compute_network.my_network.id
            subnet = data.google_compute_subnetwork.my_subnetwork.id

            vm_image {
                project      = "deeplearning-platform-release"
                # Image family can be customized based on required framework. refer https://cloud.google.com/ai-platform/notebooks/docs/images#specifying-version
                # Below image use TensorFlow Enterprise 2.x
                image_family = "tf2-ent-2-1-cu110-notebooks"
            }
            # Users having service account user role can connect to notebook instance via proxy.
            service_account = google_service_account.datawarehouse_ai_notebook_deeplearning_instance_sa.email
            
            #Whether the end user authorizes Google Cloud to install GPU driver on this instance.
            #install_gpu_driver = true

            boot_disk_type = "PD_SSD"
            boot_disk_size_gb = 110

            # This creates private notebook instance with a proxy to connect to the instance.
            no_public_ip = true
#Code Block 2.2.6.d
            # You can cutomize to use CMEK. Format of the key is projects/{project_id}/locations/{location}/keyRings/{key_ring_id}/cryptoKeys/{key_id}
            #disk_encryption = 
            #kms_key =
#Code Block 2.2.6.c
            labels = {
                data_type = "model-development"
                data_criticality = "high"
            }
            metadata = {
                terraform = "true"
            }

            # GPU config. E2 machine types does not support accelerator.
            # Shielded VM with secure boot enabled does not support accelerator.
            /*accelerator_config {
                type         = "NVIDIA_TESLA_T4"
                core_count   = 1
            }*/
#Code Block 2.2.6.b
            shielded_instance_config {
                # Integrity monitoring enabled by default
                # vTPM is enabled by default
                enable_secure_boot = true
            }
        }
        

        # ML models are only available in the regions [asia-northeast1, europe-west1, us-central1, us-east1, us-east4]
        resource "google_ml_engine_model" "default" {
            name        = "{{.datawarehouseAI_model_name}}"
            description = "Dataware house model to host model versions"
            #default_version = "v1"
            project = module.project.project_id
            # if datawarehouse_region is one of the regions 
            # regions     = ["{{.datawarehouse_region}}"]
#Code Block 2.2.8.b
            labels = {
                data_type = "ai-model"
                data_criticality = "high"
            }
            online_prediction_logging         = true
            online_prediction_console_logging = true
        }
        

        
        resource "google_dataflow_job" "bq_to_gcs_tfrecords_batch1" {
            name                    = "bq-to-gcs-tfrecords-batch"
#Code Block 2.2.5.d            
            max_workers             = {{.datawarehouse_bq_to_gcs_dataflow_job_max_workers}}
            on_delete               = "cancel"
            project                 = module.project.project_id
            network                 = "{{.datawarehouse_network_name}}"
            subnetwork              = "regions/{{.datawarehouse_region}}/subnetworks/{{.datawarehouse_subnet_name}}"
            ip_configuration        = "WORKER_IP_PRIVATE"
            region                  = "{{.datawarehouse_region}}"
            template_gcs_path       = "gs://dataflow-templates-us-central1/latest/Cloud_BigQuery_to_GCS_TensorFlow_Records"
            temp_gcs_location       = "gs://{{.datawarehouse_dataflow_temp_storage_bucket_name}}/gcs-to-bq-job1-temp"
            service_account_email  = data.google_service_account.bq_to_gcs_sa.email
            labels = {
                data_type = "enriched-data"
                data_criticality = "high"
            }
            parameters = {
                readQuery = "{{.datawarehouse_bq_to_gcs_dataflow_job1_readquery}}"

                outputDirectory = "$${module.datawarehouse_tensorflow_traning_records_storage_bucket.bucket.url}/job1-tensorflowrecords"
# Training and testing data creation percentage can be customized as per requirement.
                trainingPercentage = ".5"
                testingPercentage = ".3" 
                validationPercentage = ".2"
                #default output suffix is .tfrecord. User can customize the output suffix.
                #outputSuffix = ""
            }
        }


        resource "google_dataflow_job" "bq_to_gcs_tfrecords_batch2" {
            name                    = "bq-to-gcs-tfrecords-batch2"
#Code Block 2.2.5.d
            max_workers             = {{.datawarehouse_bq_to_gcs_dataflow_job_max_workers}}
            on_delete               = "cancel"
            project                 = module.project.project_id
            network                 = "{{.datawarehouse_network_name}}"
            subnetwork              = "regions/{{.datawarehouse_region}}/subnetworks/{{.datawarehouse_subnet_name}}"
            ip_configuration        = "WORKER_IP_PRIVATE"
            region                  = "{{.datawarehouse_region}}"
            template_gcs_path       = "gs://dataflow-templates-us-central1/latest/Cloud_BigQuery_to_GCS_TensorFlow_Records"
            temp_gcs_location       = "gs://{{.datawarehouse_dataflow_temp_storage_bucket_name}}/gcs-to-bq-job2-temp"
            service_account_email  = data.google_service_account.bq_to_gcs_sa.email
            labels = {
                data_type = "enriched-data"
                data_criticality = "high"
            }
            parameters = {
                readQuery = "{{.datawarehouse_bq_to_gcs_dataflow_job2_readquery}}"
                #"SELECT * FROM `dataflow-test-march.lake.test1`"
                outputDirectory = "$${module.datawarehouse_tensorflow_traning_records_storage_bucket.bucket.url}/job2-tensorflowrecords"
                # Training and testing data creation percentage can be customized as per requirement.
                trainingPercentage = ".5"
                testingPercentage = ".3"
                validationPercentage = ".2"
                #default output suffix is .tfrecord. User can customize the output suffix.
                #outputSuffix = ""
            }
        }

        resource "google_storage_bucket_iam_binding" "datawarehouse_dataflow_gcs_to_bq_service_account1_access_bucket" {
            bucket = "$${module.datawarehouse_tensorflow_traning_records_storage_bucket.bucket.name}"
            role = "roles/storage.objectAdmin"
            members = [
                "serviceAccount:$${data.google_service_account.bq_to_gcs_sa.email}",
                
            ]
        }
#********************** Logging Project sink *************************************

        data "google_pubsub_topic" "logging_pubsub_topic" {
            name = "logging-pubsub-topic"
            project = "{{.logging_project_id}}"
        } 
        #To Backup Audit records in to bigquery and provide capability to process them, this log sink streams logs to logging project
#Code Block 2.2.5.b
        resource "google_logging_project_sink" "my-sink" {
            name = "my-pubsub-instance-sink"
            destination ="pubsub.googleapis.com/$${data.google_pubsub_topic.logging_pubsub_topic.id}"
            #*** "pubsub.googleapis.com/projects/my-project/topics/instance-activity"
            #uncomment to add filter the logs before sending to logging project
#Code Block 2.2.2.b
            #filter = "{{.datawarehouse_project_log_sink_filter}}"
            # Use a unique writer (creates a unique service account used for writing)
            unique_writer_identity = true
        }


    EOF
    }

    resources = {
        service_accounts = [
            {
                account_id   = "ai-notebook-instance-sa"
                resource_name = "datawarehouse_ai_notebook_deeplearning_instance_sa"
                description  = "AI deep learning VM notebook instance SA"
                display_name = "AI deep learning VM notebook instance SA"
            },
        ]

        storage_buckets = [
            {
                name = "{{.datawarehouse_tensorflow_records_storage_bucket_name}}"
                resource_name = "datawarehouse_tensorflow_traning_records_storage_bucket"
#Code Block 2.2.1.b
                labels = {
                    data_type = "tensorflow-records"
                    data_criticality = "high"
                }
#Code Block 2.2.1.c
                # Uncomment and use this code block as an example to add a life cycle policy. This can be customized to match required action
                /*lifecycle_rules = [{
                    action = {
                        type          = 
                        storage_class = 
                    }
                    condition = {
                        age                   = 
                        matches_storage_class = 
                    }
                }]*/
#Code Block 2.2.1.a
                iam_members = [
                    {
                        role   = "roles/storage.objectViewer"
                        member = "group:{{.cloud_users_group}}"
                    }
                ]
            },
        ]
              
            
    }
  }
}
