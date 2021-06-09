# Google Cloud FedRAMP aligned "Marketing Data Warehouse"

![FedRAMP Aligned Marketing Data Warehouse on Google Cloud](https://user-images.githubusercontent.com/56096409/121441449-b2cf0880-c93e-11eb-91f6-5574cb61e28b.png)


You can use the architecture to deploy a marketing data warehouse on Google Cloud. The entire architecture is deployed as two projects using [Cloud Data Protection Toolkit](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite).  

## Documentation
* [Quickstart](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)
* [Prerequisites](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)
  * [Access Control](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)
* [Deployment Phases](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)
  * [Clone the repository](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)
  * [Update the variables in HCL files](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)
  * [Generate terraform files](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)
  * [Architecure deployment using terraform](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)
* [Architecture diagram]() 
* [Use case description and user considerations]() 
* [HCL files](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)
* [Useful FedRAMP links](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/README.md)

## Quickstart

1. Prerequisites
   - Access Control
2. Deployment Phases
   - Clone the repository
   - Update the variables in HashiCorp configuration language (HCL) files
   - Generate terraform files
   - Architecture deployment using terraform

## Prerequisites

Run the [Data Protection Toolkit](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite) locally on a computer or by using Google Cloud Shell. 

Before you run the toolkit locally, install the following tools:

* [Go (1.14+)](https://golang.org/doc/go1.14) - an open source programming language to build software.
* [Cloud SDK](https://cloud.google.com/sdk/install) - a set of tools for managing resources and applications hosted on Google Cloud.
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - a distributed version control system.
* [Terraform (0.14.4+)](https://www.terraform.io/downloads.html) - a cloud provisioning tool.
* [Google Workspaces](https://workspace.google.com/) or [Cloud Identity](https://cloud.google.com/identity/docs/overview) - Privileges to modify users and groups in Google Workspaces or Cloud Identity.
* [Google Cloud Organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) - A Google Cloud organization with [Billing Account](https://cloud.google.com/billing/docs)
* A domain purchased from a Domain registrar (example: Google Domains).
* Set up server-side tagging using Google Tag Manager.
  * [Create a Tag Manager server-side container.](https://developers.google.com/tag-manager/serverside#create_a_new_tag_manager_server-side_container)
  * Manually provision a [tagging server on Google Cloud App Engine.](https://developers.google.com/tag-manager/serverside/script-user-guide)


If Google Cloud Shell is used to run the toolkit, Go (1.16), Git, and Cloud SDK are preinstalled. However, newer version of Terraform must be installed in Google Cloud Shell before deploying the template using the below steps:

1. Go to [Terraform Downloads](https://www.terraform.io/downloads.html) and copy the link of 'Linux 64-bit' binary by right clicking on it.
2. Download the Linux 64-bit binary into Google Cloud Shell.
```
$ wget <link copied from Terraform Downloads>
```
3. Unzip the downloaded file.
```
$ unzip <downloaded file name>
```
4. Move the unzipped terraform binary to /usr/local/bin
```
$ sudo cp terraform /usr/local/bin
```

### Access Control
Before deploying a template, create three groups: 
* Owner: project-owners@{DOMAIN} - This group is granted the owner's role for the project, which allows members to do anything permitted by organization policies within the project. Additions to the owner’s group should be for a short term and controlled tightly.  Members of this group get owners access to the devops project to make changes to the CICD project or to make changes to the Terraform state. Make sure to include yourself as an owner of this group. Otherwise, you might lose access to the devops project after the ownership is transferred to this group.
* Admin: org-admins@{DOMAIN} - Members of this group get administrative access to the org or folder. This group can be used in break-glass situations to give humans access to the org or folder to make changes. Include yourself as a member of this group to deploy the code templates.
* Cloud-users: project-cloud-users@{DOMAIN} - Members of this group will get access to the resources deployed by the toolkit post deployment.

The user groups running the template (org-admins group) should have the following IAM roles. 
* roles/resourcemanager.organizationAdmin on the org for org deployment.
* roles/resourcemanager.folderAdmin on the folder for folder deployment (This role is required if workloads are deployed under a folder instead of organization).
* roles/resourcemanager.projectCreator on the org or folder.
* roles/billing.admin on the billing account.
* roles/owner on assured-workload projects for FedRAMP aligned workload deployment (This role is also assigned to the project-owners group).



## Deployment Phases

Data Protection Toolkit emplate deploys resources on the “Assured Workloads”, however the toolkit does not create these two Assured Workloads. Before you deploy the toolkit, create two FedRAMP Moderate Assured Workloads (one for the data warehouse project and one for the logging project) using the console or gcloud. Refer to this [Create a new workload environment.](https://cloud.google.com/assured-workloads/docs/how-to-create-workload) 


### Clone the repository

1. Clone the Data Protection Toolkit git repository to a folder (locally or on cloud shell).

```
$ git clone https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite
$ cd healthcare-data-protection-suite
```
2. Install tfengine.

```
$ go install ./cmd/tfengine
```

3. Clone the FedRAMP aligned data warehouse workload HCL files in a folder before running the tfengine

```
#clone modularised .hcl files from github to a folder in local machine or cloud shell
$ git clone [ADD LINK]()
```

4. After the HCL files are cloned, configure the variable values in commonVariables.hcl and variable.hcl files based on requirements. Refer the ‘Update the variables in HCL files’ section below for details.


## Update the variables in HCL files

This repository contains Hashicorp Configuration Language (HCL) files for deployment of FedRAMP aligned "Marketing Data Warehouse" using [Data Protection Toolkit.](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite) Data Protection Toolkit contains a suite of tools that can be used to manage key areas of your Google Cloud organization.

#### HCL files
This repository contains nine HCL files to deploy the infrastructure:
* variables.hcl: Contains variables that will be supplied to all other HCL files.
* commonVaraibles.hcl: Used to centralize common variables, which are used repetitively in variables.hcl.
* devops.hcl: Deploys devops project and terraform state storage bucket..
* network.hcl: Used to deploy two networks across two assured workload projects.
* logging.hcl: Used to deploy Logging project resources.
* datawarehouse.hcl: Used to deploy dataflow pipeline in the Data Warehouse project.
* AI-pipeline.hcl: Used to deploy AI related services in Data Warehouse project.
* datalab.hcl: Used to deploy datalab instance in Data warehouse project
* appengine.hcl: Used to map a domain to app engine application (server side container) in Data Warehouse project.

The repository contains below sample files for testing purposes:
* dept_data.txt - Sample analytics file.
* dept_data2.txt - Sample analytics file.
* schema.json - Sample schema for Cloud Storage to BigQuery transformation using Dataflow.
* transform.js - Sample UDF file Cloud Storage to BigQuery transformation using Dataflow.

#### Execution of HCL files

The toolkit (tfengine) execution starts with the commonVariables.hcl file. The commonVariables.hcl file calls the variable.hcl file, which in turn calls the other seven HCL files: devops.hcl, network.hcl, logging.hcl, datawarehouse.hcl, AI-pipeline.hcl, datalab.hcl, appengine.hcl.
 
(commonVariables.hcl →  variable.hcl file → devops.hcl, network.hcl, logging.hcl, datawarehouse.hcl, AI-pipeline.hcl, datalab.hcl, appengine.hcl)
 
Note: Variable values used in both commonVariables.hcl and variable.hcl files are for reference only. Update the variable values in commonVariables.hcl and variable.hcl files based on requirements. 


#### Key Considerations
In order to edit and customize the deployment to align to your requirements, please consider the following.
**Note: All the variables stated in the below sections reside in [commonVariables.hcl](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/Infrastructure/commonVariables.hcl) and [variables.hcl](https://github.com/GoogleCloudPlatform/gcp-fedramp-dw-quickstart/blob/master/Infrastructure/variables.hcl), and must be updated in these two files only.** 

##### devops.hcl variables

The devops.hcl file will:
* Deploy a devops project, and
* Create a terraform state storage bucket
 
Ensure that values for devops project ID "devops_project_id" (in variables.hcl) and bucket name "terraform_state_storage_bucket" (in commonVariables.hcl) are globally unique. 
 
Additionally, as needed customize the remaining variables based on the requirements.


##### network.hcl variables

The network.hcl will: 
* Create two networks i.e., one for the Data Warehouse project and the other for the Logging project. Define Subnets’ primary CIDR ranges as per requirement.
* Enable Google private service access. 
 
Additionally, as needed customize the remaining variables based on the requirements.


##### logging.hcl variables

The logging.hcl file creates: 
* Dataflow job with private worker(s)
* Bigquery dataset and table
* Pub/Sub Topic and Subscription
* IAM bindings for access

Define BigQuery table schema (in the logging.hcl file) based on the log sink filter and Pub/Sub messages format. Update the following variables with appropriate values as described.
* logging_project_id (in commonVariables.hcl): Project ID of the assured workload created for Logging resources deployment.
* logging_project_region (in commonVariables.hcl): Region selected while creating assured workload logging project.
* dataflow_temp_storage_bucket_name (in variables.hcl): A globally unique bucket name.
 
Additionally, as needed customize the remaining variables based on the requirements.
 
**Note: Assured workloads for “Logging” and “Data Warehouse” must be created before executing the Data Protection Toolkit. For details, refer to section 3.5 in the Solution Guide.**

##### datawarehouse.hcl variables

The datawarehouse.hcl file creates:
* ‘Cloud Storage to BigQuery’ Dataflow jobs
* Cloud Storage bucket for analytics data import
* BigQuery Dataset and Tables to store enriched data (transformed)
* Service Accounts for Dataflow jobs
* Cloud Storage staging and artifacts bucket for Dataflow jobs.
* IAM for access

As mentioned below, update the following variables with appropriate values.
* datawarehouse_project_id (in commonVariables.hcl):  Project ID of the assured workload created for “Data Warehouse” resources deployment.
* datawarehouse_region (in commonVariables.hcl): Region in which Data Warehouse project resources will be deployed.
* datawarehouse_dataflow_temp_storage_bucket_name (in commonVariables.hcl): A globally unique bucket name.
* datawarehouse_custom_data_import_bucket1_name (in variables.hcl): A globally unique bucket name. For the purpose of this architecture, bucket1 is where google analytics, YouTube analytics, Adwords data will be imported
* datawarehouse_custom_data_import_bucket2_name (in variables.hcl): A globally unique bucket name. . For the purpose of this architecture, bucket2 is where google third party analytics data will be imported
* datawarehouse_cutom_data_import_bucket1_path_for_dataflow (in variables.hcl): Cloud Storage bucket path of imported analytics data files in import_bucket1
* datawarehouse_cutom_data_import_bucket2_path_for_dataflow (in variables.hcl): Cloud Storage bucket path of imported analytics data files in import_bucket2
* datawarehouse_dataflow_pipeline_template_artifacts_storage_bucket_name (in variables.hcl): A globally unique bucket name.
gcs_to_bq_dataflow_job1_schema_file_local_location (in variables.hcl): Local file path to schema file used in ‘Cloud Storage to BigQuery’ dataflow job1.
* gcs_to_bq_dataflow_job1_user_defined_function_local_location (in variables.hcl): Local file path to user defined function javascript file used in ‘Cloud Storage to BigQuery’ dataflow job1.
* gcs_to_bq_dataflow_job2_schema_file_local_location (in variables.hcl): Local file path to schema file used in ‘Cloud Storage to BigQuery’ dataflow job2.
* gcs_to_bq_dataflow_job2_user_defined_function_local_location (in variables.hcl): Local file path to user defined function javascript file used in ‘Cloud Storage to BigQuery’ dataflow job2.

Additionally, as needed customize the remaining variables based on the requirements.

##### AI-pipeline.hcl variables

The AI-pipeline.hcl file creates: 
* ‘BigQuery to Cloud Storage tensorflow records’ dataflow jobs.
* AI Notebook Deep Learning VM
* ML model to host versions
* Service Accounts for Dataflow jobs
* IAM for access
 
As mentioned below, update the following variables with appropriate values.
* datawarehouse_bq_to_gcs_dataflow_job1_readquery (in variables.hcl): Query to read data from BigQuery table 1. BigQuery table 1 contains the transformed data from import_bucket1. BigQuery table 1 data is transformed to tensorflow records by ‘BigQuery to Cloud Storage tensorflow records’ dataflow job2.
* datawarehouse_bq_to_gcs_dataflow_job2_readquery (in variables.hcl): Query to read data from BigQuery table 2. BigQeury table 2 contains the transformed data from import_bucket2. BigQuery table 2 data is transformed to tensorflow records by ‘BigQuery to Cloud Storage tensorflow records’ dataflow job2.
* datawarehouse_tensorflow_records_storage_bucket_name (in variables.hcl): A globally unique bucket name.
 
Additionally, as needed customize the remaining variables based on the requirements.


##### datalab.hcl variables

The datalab.hcl file creates: 
* Datalab instance
* Service Account for Datalab instance
* IAM for access

As mentioned below, update the following variables with appropriate values.
* datawarehouseAI_datalab_user_email (in variables.hcl): User email ID to which datalab access is granted.
 
Additionally, as needed customize the remaining variables based on the requirements.


##### appengine.hcl variables

The appengine.hcl file creates: 
* Appengine Domain mapping.
* BigQuery Dataset to store Google Tag Manager (GTM) data from Appengine.
As mentioned below, update the following variables with appropriate values.
* appengine_mapping_domain_name (in variables.hcl): Domain name that will be mapped to Appengine application.
 
Additionally, as needed customize the remaining variables based on the requirements.

### Generate terraform files

To generate terraform configuration files using tfengine run the following command. This will generate 6 folders/subfolders with terraform configuration files in --output_path location.

Generated folders:
* devops
* logging/network
* logging/workload
* datawarehouse/network
* datawarehouse/dataflow-pipeline
* datawarehouse/AI-pipeline
* datawarehouse/datalab
* datawarehouse/appengine

```
# -config path is the path to downloaded .hcl files

$ tfengine --config_path=/{path-to-variablefile}/commonVariables.hcl --output_path=/{output-path}

# {path-to-variablefile}: path to commonVariable.hcl file.
# {output-path}: Folder path, where terraform configuration files are generated by tfengine.

```

### Architecture deployment using terraform

After generating terraform configurations using tfengine, run the generated main.tf files in the following order.

* Open DevOps folder and run terraform configuration. This will deploy a project and a terraform state storage bucket in the project with the name of choosing.

```
$ cd /{output-path}/devops
$ terraform init
$ terraform apply
```

* Once the project and state bucket are deployed, go to devops.hcl Data Protection Toolkit file section shown below, uncomment and set the **enable_gcs_backend** to **true.**

```
template "devops" {
  recipe_path = "recipes/devops.hcl"
  output_path = "./devops"
  data = {
    # TODO(user): Uncomment and re-run the engine after the generated devops module has been deployed.
    # Run `terraform init` in the devops module to backup its state to Cloud Storage.
    # enable_gcs_backend = true

    admins_group = {
      id = “{{.admin_group}}”
      exists = true
    }
```

* Run the tfengine command once again and force copy the state to terraform state storage bucket. Further terraform configuration deployments will use this bucket to store terraform state. 

```
$ tfengine --config_path=/{path}/commonVariables.hcl --output_path=/{path}
$ cd /{output-path}/devops
$ terraform init -force-copy

```

* Once states are transferred to the state bucket, deploy network resources in logging project (assured workload). 

```
$ cd /{output-path}/logging/network
$ terraform init
$ terraform apply
```

* Once logging network is deployed, run the below commands to deploy remaining resources in the logging project (assured workload) such as dataflow, pubsub, bigquery etc.

```
$ cd /{output-path}/logging/workload
$ terraform init
$ terraform apply
```
* Deploy the network in datawarehouse/network folder to create network and enable APIs  in Data Warehouse project.

```
$ cd /{output-path}/datawarehouse/network
$ terraform init
$ terraform apply
```

* Deploy the resources in datawarehouse/dataflow-pipeline folder to create Dataflow jobs, BigQuery dataset and tables, Cloud Storage buckets etc.
```
$ cd /{output-path}/datawarehouse/dataflow-pipeline
$ terraform init
$ terraform apply
```
* Deploy the resources in datawarehouse/AI-pipeline folder to create Dataflow jobs, Notebook Deep Learning VM, AI Model etc.
```
$ cd /{output-path}/datawarehouse/AI-pipeline
$ terraform init
$ terraform apply
```
* Deploy the resource in datawarehouse/datalab folder to create Datalab instance.
```
$ cd /{output-path}/datawarehouse/datalab
$ terraform init
$ terraform apply
```
* Deploy the additional resources in datawarehouse/appengine folder to create App Engine domain mapping, BigQuery dataset etc
```
$ cd /{output-path}/datawarehouse/appengine
$ terraform init
$ terraform apply
```
## Useful FedRAMP links

* [Google Cloud Platform supports FedRAMP compliance](https://cloud.google.com/security/compliance/fedramp/), and provides specific details on the approach to security and data protection in the [Google security whitepaper](https://cloud.google.com/security/overview/whitepaper/) and in the [Google Infrastructure Security Design Overview.](https://cloud.google.com/security/infrastructure/design/)
* To learn more about Google Cloud's Shared Responsibility Model, refer to the [Google Infrastructure Security Design Overview.](https://cloud.google.com/security/infrastructure/design/)
* Refer to the [FedRAMP Shared Security Model](https://cloud.google.com/assured-workloads/docs/concept-fedramp-moderate) and [Google Cloud FedRAMP Implementation Guide.](https://cloud.google.com/security/compliance/fedramp-guide) for additional guidance on FedRAMP shared responsibilities for Google Cloud Platform.
* For details on Google Cloud services covered by FedRAMP, refer to the [FedRAMP Marketplace](https://cloud.google.com/security/compliance/fedramp) by Google.
