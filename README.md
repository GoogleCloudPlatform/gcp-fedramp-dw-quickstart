# Google Cloud FedRAMP aligned "Marketing Data Warehouse"

You can use the =architecture to deploy a marketing data warehouse on Google Cloud. The entire architecture is deployed as two projects using [Cloud Data Protection Toolkit](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite).  

## Documentation
* [Quickstart]()
* [Prerequisites]()
  * [Access Control]()
* [Deployment Phases]()
  * [Clone the repository]()
  * [Update the variables in HCL files]()
  * [Generate terraform files]()
  * [Architecure deployment using terraform]()
* [Architecture diagram]() 
* [Use case description and user considerations]() 
* [HCL files]()
* [Useful FedRAMP links]()

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
**Note: All the variables stated in the below sections reside in [commonVariables.hcl]() and [variables.hcl](), and must be updated in these two files only.** 

##### devops variables
##### network.hcl variables
##### logging.hcl variables
##### datawarehouse.hcl variables
##### AI-pipeline.hcl variables
##### datalab.hcl variables
##### appengine.hcl variables


