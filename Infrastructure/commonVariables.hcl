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
            description = "The region in which logging project resources are deployed. Example: us-central1"
            type        = "string"
        }

#************* Definitions of Datawarehouse project variables *********************
        datawarehouse_project_id = {
            description = "project ID of pre-created assuredworkload (project) for deploying data warehouse workload."
            type        = "string"
        }
        datawarehouse_region = {
            description = "The region in which datawarehouse project resources are deployed. Example: us-central1"
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
#*************** Definition of Datawarehouse project dataflow temp storage bucket ****************

        datawarehouse_dataflow_temp_storage_bucket_name = {
            description = "Name of temp storage bucket used by dataflow jobs in datawarehouse project (assured workload)"
            type        = "string"
        }
        
#************** Definitions of logging project Newtwork variables************************
        dataflow_network_name = {
            description = "Name of the VPC used by Dataflow workers in logging project"
            type        = "string"
        }
        dataflow_subnet_name = {
            description = "Name of the subnet used by Dataflow to launch worker VMs in logging project"
            type        = "string"
        }
        dataflow_subnet_ip_range = {
            description = "IP CIDR range of dataflow subnet. dataflow worker VMs will use internal IP from this range"
            type        = "string"
        }

        
    }
}

template "variables" {
  recipe_path = "./variables.hcl"
  data = {
    # ******* Below variables values must be changed by user. Refer variable properties description in the above section before proceeding.*****************
    
    #parent_type example: "organization" or "folder"
    parent_type                             = "organization"   
    #parent_id  example: "123456789***" It is either Folder ID or Organization ID
    parent_id                               = "305010500413" 
    #billing_account ID. Example: "01F35C-D94AB9-*****"
    billing_account                         = "01F35C-D94AB9-42E990"
    #owners_group example: "project-owners@example.com" 
    owners_group                            = "three-tier-workload-owners@assuredworkload.dev"
    #admin_group example:  "org-admins@example.com"
    admin_group                             = "three-tier-workload-admins@assuredworkload.dev"
    #cloud_users_group example: "project-cloud-users@.example.com"
    cloud_users_group                       = "cloud_users@assuredworkload.dev"
    # Unique project ID for the devops project. This project is created by this template and is not a pre-existing project.
    devops_project_id                       = "datawarehouse-test-devops-7may"
    #devops_storage_region example: "us-central1"
    devops_storage_region                   = "us-west2"
    #logging_project_id is the project ID of pre-created assured workload 'logging' project 
    logging_project_id                      = "logging-workload-26may"
    #logging_project_region is the region in which logging project resources are deployed. Example: "us-central1"
    logging_project_region                  = "us-central1"
    #datawarehouse_project_id is the project ID of pre-created assured workload 'datawarehouse' project 
    datawarehouse_project_id                = "datawarehouse-26may"
    #datawarehouse_region is the region in which datawarehouse project resources are deployed. Example: "us-central1"
    datawarehouse_region                    = "us-east1"

    # ******* Below variable value must be changed by user and should be globally unique.*******
    
    #Globally unique bucket name, which stores terraform state. 
    terraform_state_storage_bucket          = "datawarehouse-state-bucket-26may"
    #Globally unique bucket name, used as staging bucket for dataflow jobs in datawarehouse project. Example: "example-dataflow-bucket"
    datawarehouse_dataflow_temp_storage_bucket_name = "datawarehouse-dataflow-temp-bucket10-26may"

    
    # ********** For below variables, default values can be retained. User can change these values based on requirement.*******

    datawarehouse_network_name              = "datawarehouse-dataflow-network"
    datawarehouse_subnet_name               = "datawarehouse-dataflow-subnet"
    datawarehouseAI_subnet_name             = "ai-ml-subnet"
    
    dataflow_network_name                   = "logging-dataflow-worker-network"
    dataflow_subnet_name                    = "logging-dataflow-worker-subnet"

    datawarehouse_enriched_data_storage_bq_dataset_name = "enriched_data_bq_dataset"
    datawarehouse_enriched_data_storage_bq_table1_name = "enriched-data-bq-table1"
    datawarehouse_enriched_data_storage_bq_table2_name = "enriched-data-bq-table2"
    
    # ******** Below variable values must be changed as per your network design. *******
    dataflow_subnet_ip_range                = "10.200.10.0/24"
    datawarehouse_subnet_ip_range           = "10.20.0.0/16"
    datawarehouseAI_subnet_ip_range         = "10.22.0.0/24"

    
  }
}
