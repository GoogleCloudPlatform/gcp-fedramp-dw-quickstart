#Marketing Data Warehouse Use Case Description


## Use Case Description

* The use case addresses Marketing Data Warehouse (Server-side tagging data) on the Google Cloud and aligns to FedRAMP standard
* The use case architecture takes into consideration deployment of resources for data collection, transformation, analysis, and visualization

## Considerations


* The use case infrastructure will be deployed under the Google Assured Workload for FedRAMP compliance
* The architecture leverages FedRAMP High and Moderate compliant GCP products 
* [Data Protection Toolkit](https://github.com/GoogleCloudPlatform/healthcare-data-protection-suite) will be leveraged and templates will be shared as HCL scripts
* For overall FedRAMP compliance, customers will be responsible to deploy and maintain FedRAMP compliant third-party solutions such as Privileged Access Management (e.g., server Administrator Access) and Vulnerability Scanner (e.g., Tenable/Nessus)
* Logging data will be in the standard format and can be exported and ingested in a SIEM by the customer when required

