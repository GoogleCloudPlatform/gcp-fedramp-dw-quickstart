schema = {
  title                = "Root module"
  description          = "This module is reusable so that it can be used both as an example and during integration tests."
  additionalProperties = false
  properties = {
        parent_type  = {
            description = "parent under which projects are residing/created. Parent type is one of the two 1) organization 2) folder"
            type        = "string"
        }
        parent_id  = {
            description = "The ID of the parent. Organization ID or Folder ID"
            type        = "string"
        }
        billing_account = {
            description = "Unique global bucket name, which stores terraform state"
            type        = "string"
        }
        owners_group    = {
            description = "Owners group for access control"
            type        = "string"
        }
        admin_group     = {
            description = "Admin group for access control"
            type        = "string"
        }
        cloud_users_group  = {
            description = "Cloud users group for access control. Cloud users group is used for post deployment access"
            type        = "string"
        }
#*********** Definitions of DevOps project variables *************************************
        devops_project_id = {
            description = "Unique project ID for the devops project. This project is created by this template"
            type        = "string"
        }
        terraform_state_storage_bucket  = {
            description = "Unique global bucket name, which stores terraform state"
            type        = "string"
        }
        devops_storage_region = {
            description = "Region in which terraform state bucket stores state files"
            type        = "string"
        }
        
#*********** Definitions of logging project variables *************************************
        logging_project_id = {
            description = "project ID of pre-created assuredworkload (project) for deploying log processing resources"
            type        = "string"
        }
        logging_project_region = {
            description = "The region used for the pre-created assured workload. Region can also be mentioned in data block."
            type        = "string"
        }

#************** Definitions of logging project Newtwork variables************************
        dataflow_network_name = {
            description = "Name of the VPC used by Dataflow workers"
            type        = "string"
        }

        dataflow_subnet_name = {
            description = "Name of the subnet used by Dataflow workers to launch VMs in"
            type        = "string"
        }

        dataflow_subnet_ip_range = {
            description = "IP CIDR range of dataflow subnet. dataflow worker VMs will use internal IP from this range"
            type        = "string"
        }

#*********** Definitions of Logging project bigquery variables *****************************
        logs_storage_bigquery_dataset_name = {
            description = "logs analyis bigquery dataset name"
            type        = "string"
        }
        logs_storage_bigquery_table_name = {
            description = "logs analysis bigquey table name"
            type        = "string"
        }
#*********** Definitions of Logging project dataflow variables *****************************
        data_flow_job_name = {
            description = "the dataflow job name (used for logs processing)"
            type        = "string"
        }
        data_flow_job_max_workers = {
            description = "the number of dataflow job workers to be created"
            type        = "number"
        }
#*********** Definitions of Logging project pubsub variables *****************************
        logs_streaming_pubsub_topic_name = {
            description = "the pubsub topic name to receive logs from three tier workload project"
            type        = "string"
        }
        logs_streaming_pubsub_topic_datatype_label = {
            description = "the pubsub topic label values used in all the resources of this project"
            type        = "string"
        }
        logs_streaming_pubsub_topic_data_criticality_label = {
            description = "the pubsub topic label values used in all the resources of this project"
            type        = "string"
        }
        logs_streaming_pubsub_subscription_name = {
            description = "the pubsub subscription name created for the above topic"
            type        = "string"
        }
        logs_streaming_pubsub_subscription_acknowledgmenet_seconds = {
            description = "the pubsub subscription acknowledgement deadline seconds"
            type        = "number"
        }
#*********** Definitions of Logging project bucket variables *****************************
        dataflow_temp_storage_bucket_name = {
            description = "Temp storage bucket name used by dataflow job"
            type        = "string"
        }
        dataflow_temp_storage_bucket_datatype_label = {
            description = "the label values used by the temp files storage bucket"
            type        = "string"
        }
        dataflow_temp_storage_bucket_data_criticality_label = {
            description = "the label values used by the temp files storage bucket"
            type        = "string"
        }   
#************* Definitions of Datawarehouse project variables *********************
        datawarehouse_project_id = {
            description = "project ID of pre-created assuredworkload (project) for deploying data warehouse workload."
            type        = "string"
        }
        datawarehouse_region = {
            description = "The region selected for the pre-created assured workload."
            type        = "string"
        }
#************** Definitions of Datawarehouse project Newtwork variables************ 
        datawarehouse_network_name = {
            description = "Name of the VPC for data warehouse workload project under which dataflow jobs will run"
            type        = "string"
        }
        datawarehouse_subnet_name = {
            description = "Name of the subnet, which is used for dataflow workers deployment"
            type        = "string"
        }
        datawarehouse_subnet_ip_range = {
            description = "IP range for the data warehouse subnet"
            type        = "string"
        }
        datawarehouseAI_subnet_name = {
            description = "Name of the subnet used by Notebook Deeplearning VM and Datalab instance "
            type        = "string"
        }
        datawarehouseAI_subnet_ip_range = {
            description = "AI platform subnet range used by Notebook Deeplearning VM and Datalab instance"
            type        = "string"
        }


#****************** Definitions of Datawarehouse project streaming Dataflow, Bucket and Bigquery Variable definitions******************
        datawarehouse_gcs_to_bq_dataflow_job_max_workers = {
            description = "The number of dataflow job workers to be created by GCS to Bigquery datafjow jobs"
            type        = "number"
        }
        datawarehouse_dataflow_temp_storage_bucket_name = {
            description = "Name of temp storage bucket used by dataflow jobs in datawarehouse project (assured workload)"
            type        = "string"
        }
        datawarehouse_custom_data_import_bucket1_name = {
            description = "Name of the bucket where google analytics, youtube analytics, Adwords data will be imported"
            type        = "string"
        }
        datawarehouse_cutom_data_import_bucket1_path_for_dataflow = {
            description = "Bucket location path where analytics data files are imported, for example: if files path pattern is gs:examplebucket/path1/datafile*.txt this variable value will be path1/datafile*.txt. Asterisk * in datafile*.txt used to transform all the files uploaded with same name."
            type        = "string"
        }
        datawarehouse_custom_data_import_bucket2_name = {
            description = "Name of the bucket where google third party analytics data will be imported"
            type        = "string"
        }
        datawarehouse_cutom_data_import_bucket2_path_for_dataflow = {
            description = "Bucket location path where analytics data files are imported, for example: if files path pattern is gs:examplebucket/path1/datafile*.txt this variable value will be path1/datafile*.txt. Asterisk * in datafile*.txt used to transform all the files uploaded with same name."
            type        = "string"
        }
        datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket_name = {
            description = "Bucket where schema.json, user definedfunction javascript files are uploaded. Both Dataflow GCS to Bigquery jobs import schema.json and udf function (example. Transform.js) files in to template parameters"
            type        = "string"
        }
        datawarehouse_enriched_data_storage_bq_dataset_name = {
            description = "Bigquery dataset name where all the analytics transformed data will be inject in streaming mode."
            type        = "string"
        }
        datawarehouse_enriched_data_storage_bq_table1_name = {
            description = "Bigquery table name where all the analytics transformed data will be inject in streaming mode by GCS to Bigquery dataflow job1 ."
            type        = "string"
        }
        datawarehouse_enriched_data_storage_bq_table2_name = {
            description = "Bigquery table name where all the analytics transformed data will be inject in streaming mode by GCS to Bigquery dataflow job2."
            type        = "string"
        } 
        gcs_to_bq_dataflow_job1_schema_file_local_location = {
            description = "Local path to schema json file used by GCS to Bigquery dataflow job1, that will be uploaded to datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket."
            type        = "string"
        }
        gcs_to_bq_dataflow_job1_user_defined_function_local_location = {
            description = "Local path to user defined function javascript file file used by GCS to Bigquery dataflow job1, that will be uploaded to datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket."
            type        = "string"
        }
        gcs_to_bq_dataflow_job2_schema_file_local_location = {
            description = "Local path to schema json file used by GCS to Bigquery dataflow job2, that will be uploaded to datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket."
            type        = "string"
        }
        gcs_to_bq_dataflow_job2_user_defined_function_local_location = {
            description = "Local path to user defined function javascript file file used by GCS to Bigquery dataflow job2, that will be uploaded to datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket."
            type        = "string"
        }

#************** Definitions of Datawarehouse project AI pipeline variable definitions ************
        datawarehouse_bq_to_gcs_dataflow_job_max_workers = {
            description = "The number of dataflow job workers to be created by Bigquery to GCS tfrecords datafjow job"
            type        = "number"
        }
        
        datawarehouse_bq_to_gcs_dataflow_job1_readquery = {
            description = "Bigquery read query, to query the table datawarehouse_enriched_data_storage_bq_table1 and tranfrom the data to tensorflow records"
            type        = "string"
        }
        datawarehouse_bq_to_gcs_dataflow_job2_readquery = {
            description = "Bigquery read query, to query the table datawarehouse_enriched_data_storage_bq_table2 and tranfrom the data to tensorflow records"
            type        = "string"
        }
        datawarehouse_tensorflow_records_storage_bucket_name = {
            description = "Name of the bucket, where transformed tensorflow records data is stored."
            type        = "string"
        }
        datawarehouseAI_notebooks_instance_name = {
            description = "Name of the AI notebook deeplearning VM."
            type        = "string"
        }
        datawarehouseAI_model_name = {
            description = "AI platform Model Name to hold model versions. "
            type        = "string"
        }

# ********************** Definitions of Datawarehouse project datalab variables ***************
        datawarehouseAI_datalab_instance_name = {
            description = "Datalab instance name"
            type        = "string"
        }
        datawarehouseAI_datalab_user_email = {
            description = "email of the user who will connect to datalab instance for visualization. Datalab is a single user service. "
            type        = "string"         
        }

#********************** Definitions of Datawarehouse project app engine variables *************
        appengine_mapping_domain_name  = {
            description = "Domain name that will be mapped to App Engine. A google managed certificate is created for this domain."
            type        = "string"
        }
        datawarehouse_gtm_appengine_data_storage_bq_dataset_name = {
            description = "Bigquery dataset name where Google Tag Manager tagserver (appengine) data is stored."
            type        = "string"
        }

        
#******************* Definitions of Datawarehouse project Logsink to logging project Variable ***********
        datawarehouse_project_log_sink_filter = {
            description = "the filter string to send only certain logs to logging project"
            type        = "string"
        }

        
    }
}

# Note: Varible values, which are in the format {{.}} will be auto filled from commonVariables.hcl file. Only configure remaining variables.
template "devops" {
  recipe_path = "./devops.hcl"
  data = {

    # ******* Do not change below variables. These values are supplied by commonVariables.hcl *******
    parent_type                             = "{{.parent_type}}"
    parent_id                               = "{{.parent_id}}" 
    billing_account                         = "{{.billing_account}}"
    owners_group                            = "{{.owners_group}}"
    admin_group                             = "{{.admin_group}}"
    cloud_users_group                       = "{{.cloud_users_group}}"
    devops_project_id                       = "{{.devops_project_id}}"
    devops_storage_region                   = "{{.devops_storage_region}}"
    terraform_state_storage_bucket          = "{{.terraform_state_storage_bucket}}"

  }
}

template "logging" {
  recipe_path = "./logging.hcl"
  data = { 
    # ******* Do not change below variables. These values are supplied by commonVariables.hcl *******
    parent_type                                                 = "{{.parent_type}}"   
    parent_id                                                   = "{{.parent_id}}" 
    billing_account                                             = "{{.billing_account}}"
    terraform_state_storage_bucket                              = "{{.terraform_state_storage_bucket}}"
    owners_group                                                = "{{.owners_group}}"
    admin_group                                                 = "{{.admin_group}}"
    cloud_users_group                                           = "{{.cloud_users_group}}"
    logging_project_id                                          = "{{.logging_project_id}}"
    logging_project_region                                      = "{{.logging_project_region}}"
    dataflow_network_name                                       = "{{.dataflow_network_name}}"
    dataflow_subnet_name                                        = "{{.dataflow_subnet_name}}"
    dataflow_subnet_ip_range                                    = "{{.dataflow_subnet_ip_range}}"

    # ********** For below variables, default values can be retained. User can change these values based on requirement*******
    logs_storage_bigquery_dataset_name                          = "logs_storage_dataset" 
    logs_storage_bigquery_table_name                            = "central-logs-table1"
    data_flow_job_name                                          = "log-streaming1"
    data_flow_job_max_workers                                   = 2
    logs_streaming_pubsub_topic_name                            = "logging-pubsub-topic"
    logs_streaming_pubsub_topic_datatype_label                  = "logs"
    logs_streaming_pubsub_topic_data_criticality_label          = "logs-processing"
    logs_streaming_pubsub_subscription_name                     = "logging-pubsub-subscriptions"
    logs_streaming_pubsub_subscription_acknowledgmenet_seconds  = 20
    dataflow_temp_storage_bucket_datatype_label                 = "temp-data"
    dataflow_temp_storage_bucket_data_criticality_label         = "low"

    # ******* Below variable value must be changed and should be globally unique********
    #Globally unique bucket name, used as staging bucket for dataflow job in logging project. Example: "example-dataflow-bucket"
    dataflow_temp_storage_bucket_name                           = "dataflow-temp-storage-bucket10-7may"
    
    
  }
}

template "network" {
  recipe_path = "./network.hcl"
  data = {

    # ******* Do not change below variables. These values are supplied by commonVariables.hcl*******
    parent_type                             = "{{.parent_type}}"   
    parent_id                               = "{{.parent_id}}" 
    billing_account                         = "{{.billing_account}}"
    terraform_state_storage_bucket          = "{{.terraform_state_storage_bucket}}"
    owners_group                            = "{{.owners_group}}"
    admin_group                             = "{{.admin_group}}"
    cloud_users_group                       = "{{.cloud_users_group}}"
    datawarehouse_project_id                = "{{.datawarehouse_project_id}}"
    datawarehouse_region                    = "{{.datawarehouse_region}}"
    datawarehouse_network_name              = "{{.datawarehouse_network_name}}"
    datawarehouse_subnet_name               = "{{.datawarehouse_subnet_name}}"
    datawarehouse_subnet_ip_range           = "{{.datawarehouse_subnet_ip_range}}"
    datawarehouseAI_subnet_name             = "{{.datawarehouseAI_subnet_name}}"
    datawarehouseAI_subnet_ip_range         = "{{.datawarehouseAI_subnet_ip_range}}"
    logging_project_id                      = "{{.logging_project_id}}"
    logging_project_region                  = "{{.logging_project_region}}"
    dataflow_network_name                   = "{{.dataflow_network_name}}"
    dataflow_subnet_name                    = "{{.dataflow_subnet_name}}"
    dataflow_subnet_ip_range                = "{{.dataflow_subnet_ip_range}}"
  }
}


template "datawarehouse" {
  recipe_path = "./datawarehouse.hcl"
  data = {
    # ******* Do not change below variables. These values are supplied by commonVariables.hcl*******
    parent_type                             = "{{.parent_type}}"   
    parent_id                               = "{{.parent_id}}" 
    billing_account                         = "{{.billing_account}}"
    terraform_state_storage_bucket          = "{{.terraform_state_storage_bucket}}"
    owners_group                            = "{{.owners_group}}"
    admin_group                             = "{{.admin_group}}"
    cloud_users_group                       = "{{.cloud_users_group}}"
    datawarehouse_project_id                = "{{.datawarehouse_project_id}}"
    datawarehouse_region                    = "{{.datawarehouse_region}}"
    datawarehouse_network_name              = "{{.datawarehouse_network_name}}"
    datawarehouse_subnet_name               = "{{.datawarehouse_subnet_name}}"
    datawarehouse_subnet_ip_range           = "{{.datawarehouse_subnet_ip_range}}"
    datawarehouse_dataflow_temp_storage_bucket_name = "{{.datawarehouse_dataflow_temp_storage_bucket_name}}"

    # ******* Below variable value must be changed. Bucket names should be globally unique, file path should be unique to your bucket path ************

    #Globally unique bucket name, where google analytics, youtube analytics, Adwords data will be imported Example: "datawarehouse-custom-import-bucket1"
    datawarehouse_custom_data_import_bucket1_name = "datawarehouse-custom-import-bucket1-26may"
    
    #Example: If analytics data is imported from google analytics/youtube analytics in to the bucket1 as txt files, and the path of the bucket is 'gs://examplebucket/folder1/userdata*.txt' then enter path value below as /folder1/userdata*.txt
    datawarehouse_cutom_data_import_bucket1_path_for_dataflow = "/files/dept_data*.txt"
     
    #Globally unique bucket name, where third party analytics data will be imported Example: "datawarehouse-custom-import-bucket2"
    datawarehouse_custom_data_import_bucket2_name = "datawarehouse-custom-import-bucket2-26may"
    
    #Example: If analytics data is imported from third party analytics in to the bucket2 as txt files, and the path of the bucket is 'gs://examplebucket/folder1/userdata*.txt' then enter path value below as /folder1/userdata*.txt
    datawarehouse_cutom_data_import_bucket2_path_for_dataflow = "/files/dept_data*.txt"
    
    # datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket stores 'schema json' and 'user defined function java script' files, which are used by "GCS to Bigquery" dataflow jobs
    datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket_name = "datawarehouse-dataflow-pipeline-template-bucket-26may"
        
    # ********** For below variables, default values can be retained. User can change these values based on requirement.**********
    
    datawarehouse_gcs_to_bq_dataflow_job_max_workers = 2
    datawarehouse_enriched_data_storage_bq_dataset_name = "{{.datawarehouse_enriched_data_storage_bq_dataset_name}}"
    datawarehouse_enriched_data_storage_bq_table1_name = "{{.datawarehouse_enriched_data_storage_bq_table1_name}}"
    datawarehouse_enriched_data_storage_bq_table2_name = "{{.datawarehouse_enriched_data_storage_bq_table2_name}}"  


    # ******* Below variable value must be changed ************************

    # Location of 'schema json' file and 'user defined function (UDF) java script' file in your local computer or cloud shell (from where you are running the template) 
    gcs_to_bq_dataflow_job1_schema_file_local_location = "{path to schema file}/usecase-2/schema.json"
    gcs_to_bq_dataflow_job1_user_defined_function_local_location = "{path to UDF file}/usecase-2/transform.js"
    gcs_to_bq_dataflow_job2_schema_file_local_location = "{path to schema file}/usecase-2/schema.json"
    gcs_to_bq_dataflow_job2_user_defined_function_local_location = "{path to UDF file}/usecase-2/transform.js"  
    

    # Location of BigQuery table schema file in your local computer or cloud shell (from where you are running the template)
    datawarehouse_enriched_data_storage_bq_table1_schema_path = "{path to schema file}/usecase-2/tableschema.json"
    datawarehouse_enriched_data_storage_bq_table2_schema_path = "{path to schema file}/usecase-2/tableschema.json"



  }
}


template "AI-pipeline" {
  recipe_path = "./AI-pipeline.hcl"
  data = {
    # ******* Do not change below variables. These values are supplied by commonVariables.hcl*******
    parent_type                             = "{{.parent_type}}"   
    parent_id                               = "{{.parent_id}}" 
    billing_account                         = "{{.billing_account}}"
    terraform_state_storage_bucket          = "{{.terraform_state_storage_bucket}}"
    owners_group                            = "{{.owners_group}}"
    admin_group                             = "{{.admin_group}}"
    cloud_users_group                       = "{{.cloud_users_group}}"
    logging_project_id                      = "{{.logging_project_id}}"
    logging_project_region                  = "{{.logging_project_region}}"
    datawarehouse_project_id                = "{{.datawarehouse_project_id}}"
    datawarehouse_region                    = "{{.datawarehouse_region}}"
    datawarehouse_network_name              = "{{.datawarehouse_network_name}}"
    datawarehouse_subnet_name               = "{{.datawarehouse_subnet_name}}"
    datawarehouse_subnet_ip_range           = "{{.datawarehouse_subnet_ip_range}}"
    datawarehouseAI_subnet_name             = "{{.datawarehouseAI_subnet_name}}"
    datawarehouseAI_subnet_ip_range         = "{{.datawarehouseAI_subnet_ip_range}}"
    datawarehouse_dataflow_temp_storage_bucket_name = "{{.datawarehouse_dataflow_temp_storage_bucket_name}}"
    
    # ********** For below variables, default values can be retained. User can change these values based on requirement *******

    datawarehouse_bq_to_gcs_dataflow_job_max_workers = 2
    datawarehouseAI_notebooks_instance_name = "notebook-instance"

    # To host the model versions. Model location will default to 'us-central1'. ML model only supports 'us-central1', 'us-east1', and 'us-east4'. 
    # If you want to launch ML model in other supported regions, uncomment "region" argument in resoruce "google_ml_engine_model" inside AI-pipline.hcl. 
    datawarehouseAI_model_name = "ai_google_analytics_model" 
    
    datawarehouse_project_log_sink_filter = "resource.type = gce_instance AND severity >= WARNING"
    
    # ******* Below variable value must be changed. Select query should be unique based on column data that have to be converted to tensorflow records. Bucket names should be globally unique *********
   
    datawarehouse_bq_to_gcs_dataflow_job1_readquery = "select * from `{{.datawarehouse_project_id}}.{{.datawarehouse_enriched_data_storage_bq_dataset_name}}.{{.datawarehouse_enriched_data_storage_bq_table1_name}}`"
    datawarehouse_bq_to_gcs_dataflow_job2_readquery = "select * from `{{.datawarehouse_project_id}}.{{.datawarehouse_enriched_data_storage_bq_dataset_name}}.{{.datawarehouse_enriched_data_storage_bq_table2_name}}`"
    
    #Globally unique bucket name, where transformed tensorflow records data from bigquery is stored
    datawarehouse_tensorflow_records_storage_bucket_name = "datawarehouse-tfrecord-bucket-26may"
    
  }
}

template "datalab" {
  recipe_path = "./datalab.hcl"
  data = {
    # ******* Do not change below variables. These values are supplied by commonVariables.hcl *******
    parent_type                             = "{{.parent_type}}"   
    parent_id                               = "{{.parent_id}}" 
    billing_account                         = "{{.billing_account}}"
    terraform_state_storage_bucket          = "{{.terraform_state_storage_bucket}}"
    owners_group                            = "{{.owners_group}}"
    admin_group                             = "{{.admin_group}}"
    cloud_users_group                       = "{{.cloud_users_group}}"
    datawarehouse_project_id                = "{{.datawarehouse_project_id}}"
    datawarehouse_region                    = "{{.datawarehouse_region}}"
    datawarehouse_network_name              = "{{.datawarehouse_network_name}}"
    datawarehouseAI_subnet_name             = "{{.datawarehouseAI_subnet_name}}"
    datawarehouseAI_subnet_ip_range         = "{{.datawarehouseAI_subnet_ip_range}}"

    # ********** For below variables, default values can be retained. User can change these values based on requirement *******

    datawarehouseAI_datalab_instance_name = "datalab-instance"

    # ******* Below variable values must be changed by user *****************
    
    # Datalab is a single user instance. example: "user1@example.com
    datawarehouseAI_datalab_user_email = "dinesh.chintalapati@assuredworkload.dev"
    
  }
}

template "appengine" {
  recipe_path = "./appengine.hcl"
  data = {
    parent_type                             = "{{.parent_type}}"   
    parent_id                               = "{{.parent_id}}" 
    billing_account                         = "{{.billing_account}}"
    terraform_state_storage_bucket          = "{{.terraform_state_storage_bucket}}"
    owners_group                            = "{{.owners_group}}"
    admin_group                             = "{{.admin_group}}"
    cloud_users_group                       = "{{.cloud_users_group}}"
    datawarehouse_project_id                = "{{.datawarehouse_project_id}}"
    datawarehouse_region                    = "{{.datawarehouse_region}}"
    datawarehouse_network_name              = "{{.datawarehouse_network_name}}"
    datawarehouseAI_subnet_name             = "{{.datawarehouseAI_subnet_name}}"
    datawarehouseAI_subnet_ip_range         = "{{.datawarehouseAI_subnet_ip_range}}"

    # ******* Below variable values must be changed and should be globally unique*********
    
    # Format of the appengine_mapping_domain_name should be "example.us", "example.dev"
    appengine_mapping_domain_name  = "assuredworkload.dev"
    
    # ********** For below variables, default values can be retained. User can change these values based on requirement.*******
    datawarehouse_gtm_appengine_data_storage_bq_dataset_name = "gtm_data_storage_bq_dataset10"

  }
}



