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

template "datawarehouse" {
  recipe_path = "git://github.com/GoogleCloudPlatform/healthcare-data-protection-suite//templates/tfengine/recipes/project.hcl"
  output_path = "./datawarehouse/dataflow-pipeline"
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
        
        resource "google_service_account_iam_member" "cloud_users_access_to_sa1" {
            service_account_id = "$${google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_1.name}"
            role               = "roles/iam.serviceAccountUser"
            member             = "group:{{.cloud_users_group}}"
        }

        resource "google_service_account_iam_member" "cloud_users_access_to_sa2" {
            service_account_id = "$${google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_2.name}"
            role               = "roles/iam.serviceAccountUser"
            member             = "group:{{.cloud_users_group}}"
        }

        resource "google_service_account_iam_member" "cloud_users_access_to_sa3" {
            service_account_id = "$${google_service_account.data_flow_job_bq_to_gcs_tfrecords_batch_service_account.name}"
            role               = "roles/iam.serviceAccountUser"
            member             = "group:{{.cloud_users_group}}"
        }
#Code Block 2.2.2.b
        resource "google_project_iam_audit_config" "project_audit_config" {
            project = module.project.project_id
            service = "allServices"
            audit_log_config {
                log_type = "DATA_READ"
            }
            audit_log_config {
                log_type = "DATA_WRITE"
            }
            audit_log_config {
                log_type = "ADMIN_READ"
            }
        }
        resource "google_storage_bucket_object" "gcs_to_bq_job1_schema" {
            name   = "schema/schema1.json"
            source = "{{.gcs_to_bq_dataflow_job1_schema_file_local_location}}"
            bucket = module.datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket.bucket.name
        }
        resource "google_storage_bucket_object" "gcs_to_bq_job1_udf" {
            name   = "udf/transform1.js"
            source = "{{.gcs_to_bq_dataflow_job1_user_defined_function_local_location}}"
            bucket = module.datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket.bucket.name
        }

        resource "google_storage_bucket_object" "gcs_to_bq_job2_schema" {
            name   = "schema/schema2.json"
            source = "{{.gcs_to_bq_dataflow_job2_schema_file_local_location}}"
            bucket = module.datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket.bucket.name
        }
        resource "google_storage_bucket_object" "gcs_to_bq_job2_udf" {
            name   = "udf/transform2.js"
            source = "{{.gcs_to_bq_dataflow_job2_user_defined_function_local_location}}"
            bucket = module.datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket.bucket.name
        }

        resource "google_bigquery_table" "enriched_data_table1" {
            dataset_id = "$${module.datawarehouse_enriched_data_storage_bq_dataset_name.bigquery_dataset.dataset_id}"
            table_id = "{{.datawarehouse_enriched_data_storage_bq_table1_name}}"
            project = module.project.project_id
            labels = {
                data_type = "enriched-data"
                data_criticality = "high"
            }
            # Uncomment and provide schema file path. If left unchanges, this will create an empty table.
            # Schema also can be given inline.
            schema = file("{{.datawarehouse_enriched_data_storage_bq_table1_schema_path}}")
            /*<<SCRIPT               
            SCRIPT*/ 
        }

        resource "google_bigquery_table" "enriched_data_table2" {
            dataset_id = "$${module.datawarehouse_enriched_data_storage_bq_dataset_name.bigquery_dataset.dataset_id}"
            table_id = "{{.datawarehouse_enriched_data_storage_bq_table2_name}}"
            project = module.project.project_id
            labels = {
                data_type = "enriched-data"
                data_criticality = "high"
            }
            # Uncomment and provide schema file path. If left unchanges, this will create an empty table.
            # Schema also can be given inline.
            schema = file("{{.datawarehouse_enriched_data_storage_bq_table2_schema_path}}")
            /*<<SCRIPT
            SCRIPT*/     
        }

        resource "google_dataflow_job" "gcs_to_bq_streaming_1" {
            name                    = "gcs-to-bq-streaming"
            max_workers             = {{.datawarehouse_gcs_to_bq_dataflow_job_max_workers}}
            on_delete               = "cancel"
            project                 = module.project.project_id
            network                 = "{{.datawarehouse_network_name}}"
            subnetwork              = "regions/{{.datawarehouse_region}}/subnetworks/{{.datawarehouse_subnet_name}}"
            ip_configuration        = "WORKER_IP_PRIVATE"
            region                  = "{{.datawarehouse_region}}"
            depends_on              = [google_project_iam_binding.data_flow_service_account_access_worker]

            #This is the path to google provided streaming template. User can give a different GCS path to use a custom template. Update the template parameters accordingly
            template_gcs_path       = "gs://dataflow-templates-us-central1/latest/Stream_GCS_Text_to_BigQuery"
            temp_gcs_location       = "$${module.datawarehouse_dataflow_temp_storage_bucket.bucket.url}/gcs-to-bq-job1-temp"
            service_account_email  = google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_1.email
            labels = {
                data_type = "custom-import-data"
                data_criticality = "high"
            }
            parameters = {
                javascriptTextTransformGcsPath = "gs://$${google_storage_bucket_object.gcs_to_bq_job1_udf.bucket}/$${google_storage_bucket_object.gcs_to_bq_job1_udf.name}"
                javascriptTextTransformFunctionName = "transform"
                JSONPath = "gs://$${google_storage_bucket_object.gcs_to_bq_job1_schema.bucket}/$${google_storage_bucket_object.gcs_to_bq_job1_schema.name}"
                outputTable =  "$${google_bigquery_table.enriched_data_table1.project}:$${google_bigquery_table.enriched_data_table1.dataset_id}.$${google_bigquery_table.enriched_data_table1.table_id}"
                inputFilePattern = "$${module.datawarehouse_custom_data_import_bucket_1.bucket.url}{{.datawarehouse_cutom_data_import_bucket1_path_for_dataflow}}" 
                bigQueryLoadingTemporaryDirectory = "$${module.datawarehouse_dataflow_temp_storage_bucket.bucket.url}/gcs-to-bq-job1-temp/staging"
            }
        }

        resource "google_dataflow_job" "gcs_to_bq_streaming_2" {
            name                    = "gcs-to-bq-streaming2"
            max_workers             = 2
            on_delete               = "cancel"
            project                 = module.project.project_id
            network                 = "datawarehouse-dataflow-network"
            subnetwork              = "regions/{{.datawarehouse_region}}/subnetworks/{{.datawarehouse_subnet_name}}"
            ip_configuration        = "WORKER_IP_PRIVATE"
            region                  = "{{.datawarehouse_region}}"
            depends_on              = [google_project_iam_binding.data_flow_service_account_access_worker]
            
            #This is the path to google provided streaming template. User can give a different GCS path to use a custom template. Update the template parameters accordingly
            template_gcs_path       = "gs://dataflow-templates-us-central1/latest/Stream_GCS_Text_to_BigQuery"
            temp_gcs_location       = "$${module.datawarehouse_dataflow_temp_storage_bucket.bucket.url}/gcs-to-bq-job2-temp"
            service_account_email  = google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_2.email
            labels = {
                data_type = "custom-import-data"
                data_criticality = "high"
            }
            parameters = {
                javascriptTextTransformGcsPath = "gs://$${google_storage_bucket_object.gcs_to_bq_job2_udf.bucket}/$${google_storage_bucket_object.gcs_to_bq_job2_udf.name}"
                javascriptTextTransformFunctionName = "transform"
                JSONPath = "gs://$${google_storage_bucket_object.gcs_to_bq_job2_schema.bucket}/$${google_storage_bucket_object.gcs_to_bq_job2_schema.name}"
                outputTable =  "$${google_bigquery_table.enriched_data_table2.project}:$${google_bigquery_table.enriched_data_table2.dataset_id}.$${google_bigquery_table.enriched_data_table2.table_id}"
                inputFilePattern = "$${module.datawarehouse_custom_data_import_bucket_2.bucket.url}/files/dept_data*.txt" 
                bigQueryLoadingTemporaryDirectory = "$${module.datawarehouse_dataflow_temp_storage_bucket.bucket.url}/gcs-to-bq-job2-temp/staging"
            }
        }
        
       



       
#**********************************Access to dataflow Temp bucket**********************************************************************
        resource "google_storage_bucket_iam_binding" "datawarehouse_dataflow_temp_bucket_acccess" {
            bucket = "$${module.datawarehouse_dataflow_temp_storage_bucket.bucket.name}"
            role = "roles/storage.objectAdmin"
            members = [
                "serviceAccount:$${google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_1.email}",
                "serviceAccount:$${google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_2.email}",
                "serviceAccount:$${google_service_account.data_flow_job_bq_to_gcs_tfrecords_batch_service_account.email}",
                "serviceAccount:service-$${data.google_project.project_number.number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
            ]
        }

#******************************** Access to gcs-to-bq streaming dataflow job 1 ****************************
        # BigQuery access is given to dataflow service account
        resource "google_bigquery_dataset_access" "datawarehouse_dataflow_gcs_to_bq_service_account1_access_bigquery" {
            dataset_id    = "$${module.datawarehouse_enriched_data_storage_bq_dataset_name.bigquery_dataset.dataset_id}"
            role          = "roles/bigquery.dataEditor"
            user_by_email = google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_1.email
        }
        # # Cloud Storage access is given to dataflow service account
        resource "google_storage_bucket_iam_binding" "datawarehouse_dataflow_gcs_to_bq_service_account1_access_bucket" {
            bucket = "$${module.datawarehouse_custom_data_import_bucket_1.bucket.name}"
            role = "roles/storage.objectAdmin"
            members = [
                "serviceAccount:$${google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_1.email}",
                "serviceAccount:service-$${data.google_project.project_number.number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
            ]
        }

#******************************** Access to gcs-to-bq streaming dataflow job 2 ****************************
        #
        resource "google_bigquery_dataset_access" "datawarehouse_dataflow_gcs_to_bq_service_account2_access_bigquery" {
            dataset_id    = "$${module.datawarehouse_enriched_data_storage_bq_dataset_name.bigquery_dataset.dataset_id}"
            role          = "roles/bigquery.dataEditor"
            user_by_email = google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_2.email
        }
        # 
        resource "google_storage_bucket_iam_binding" "datawarehouse_dataflow_gcs_to_bq_service_account2_access_bucket" {
            bucket = "$${module.datawarehouse_custom_data_import_bucket_2.bucket.name}"
            role = "roles/storage.objectAdmin"
            members = [
                "serviceAccount:$${google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_2.email}",
                "serviceAccount:service-$${data.google_project.project_number.number}@dataflow-service-producer-prod.iam.gserviceaccount.com",
            ]
        }


        # 
        resource "google_project_iam_binding" "data_flow_service_account_access_worker" {
            project = module.project.project_id
            role    = "roles/dataflow.worker"

            members = [
                "serviceAccount:$${google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_1.email}",
                "serviceAccount:$${google_service_account.data_flow_job_gcs_to_bq_streaming_service_account_2.email}",
                "serviceAccount:$${google_service_account.data_flow_job_bq_to_gcs_tfrecords_batch_service_account.email}",
            ]
        }     
        
    EOF
    }

    resources = {

        service_accounts = [
            {
                account_id   = "dataflow-job-gcs-to-bq-sa-1"
                resource_name = "data_flow_job_gcs_to_bq_streaming_service_account_1"
                description  = "GCS to BigQuery dataflow Job SA 1"
                display_name = "GCS to BigQuery dataflow Job SA 1"
            },
            {
                account_id   = "dataflow-job-gcs-to-bq-sa-2"
                resource_name = "data_flow_job_gcs_to_bq_streaming_service_account_2"
                description  = "GCS to BigQuery dataflow Job SA 2"
                display_name = "GCS to BigQuery dataflow Job SA 2"
            },
            {
                account_id   = "dataflow-job-bq-to-gcs-tf-sa"
                resource_name = "data_flow_job_bq_to_gcs_tfrecords_batch_service_account"
                description  = "BigQuery to GCS TF Records Job SAA"
                display_name = "BigQuery to GCS TF Records Job SA"
            },
        ]
        storage_buckets = [
            {
                name = "{{.datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket_name}}"
                resource_name = "datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket"
#Code Block 2.2.1.b
                labels = {
                    data_type = "temp-data"
                    data_criticality = "low"
                }
#Code Block 2.2.1.a
                iam_members = [
                    {
                        role   = "roles/storage.objectViewer"
                        member = "group:{{.cloud_users_group}}"
                    }
                ]
            },
            {
                name = "{{.datawarehouse_custom_data_import_bucket1_name}}"
                resource_name = "datawarehouse_custom_data_import_bucket_1"
#Code Block 2.2.1.b
                labels = {
                    data_type = "custom-import-data"
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
            {
                name = "{{.datawarehouse_custom_data_import_bucket2_name}}"
                resource_name = "datawarehouse_custom_data_import_bucket_2"
#Code Block 2.2.1.b
                labels = {
                    data_type = "custom-import-data"
                    data_criticality = "high"
                }
#Code Block 2.2.1.c
                #  Uncomment and use this code block as an example to add a life cycle policy. This can be customized to match required action
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
            {
                name = "{{.datawarehouse_dataflow_temp_storage_bucket_name}}"
                resource_name = "datawarehouse_dataflow_temp_storage_bucket"
#Code Block 2.2.1.b             
                labels = {
                    data_type = "temp-data"
                    data_criticality = "low"
                }
#Code Block 2.2.1.a
                iam_members = [
                    {
                        role   = "roles/storage.objectViewer"
                        member = "group:{{.cloud_users_group}}"
                    }
                ]
            }
        ]
        
        bigquery_datasets = [
            {
                #Override Terraform resource name as it cannot start with a number.
                resource_name               = "datawarehouse_enriched_data_storage_bq_dataset_name"
                dataset_id                  = "{{.datawarehouse_enriched_data_storage_bq_dataset_name}}"
#Code Block 2.2.2.c
                labels = {
                    data_type = "enriched-data"
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
                }
                ]
            }
        ]
    }
  }
}
