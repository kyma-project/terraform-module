# terraform-sap-kyma-on-btp

## Status

[![REUSE status](https://api.reuse.software/badge/github.com/kyma-project/terraform-module)](https://api.reuse.software/info/github.com/kyma-project/terraform-module)

## Overview

Terraform module that creates kyma runtime in SAP BTP platform.

![image](./assets/sequence.drawio.svg)

### Input Variables (TF vars)

| NAME                       | MANDATORY | DEFAULT VALUE             | DESCRIPTION                                                                                                                                        |
|----------------------------|-----------|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| BTP_GLOBAL_ACCOUNT         | true      |                           | UUID of SAP BTP Global Account                                                                                                                     |
| BTP_USE_SUBACCOUNT_ID      | false     |                           | Provide an UUID of existing SAP BTP Subaccount to be used. Should not be combined with `BTP_NEW_SUBACCOUNT_*` inputs.                              |
| BTP_NEW_SUBACCOUNT_NAME    | false     |                           | Provide a name for a new SAP BTP Subaccount to be created. Should not be combined with  `BTP_USE_SUBACCOUNT_ID` input.                             |
| BTP_NEW_SUBACCOUNT_REGION  | false     |                           | Provide a region for a new SAP BTP Subaccount to be created. Should not be combined with  `BTP_USE_SUBACCOUNT_ID` input.                           |
| BTP_CUSTOM_IAS_TENANT      | true      |                           | Provide the name of the custom SAP IAS tenant that is an authentication provider for the technical user.                                           |
| BTP_BACKEND_URL            | false     | https://cli.btp.cloud.sap | URL of the BTP backend API (on canary environment this has to be set to  `https://cpcli.cf.sap.hana.ondemand.com`).                                |
| BTP_KYMA_PLAN              | false     | azure                     | Use one of a valid kyma plans that you are entitled to use (One of: `azure`, `gcp`, `aws`,`sap-converged-cloud`)                                   |
| BTP_KYMA_REGION            | false     | westeurope                | Use a valid kyma region that matches your selected kyma plan                                                                                       |
| BTP_KYMA_AUTOSCALER_MIN    | false     | 3                         | Minimum number of nodes |
| BTP_KYMA_AUTOSCALER_MAX    | false     | 10                        | Maximum number of nodes |



### Required Providers

Terraform module for Kyma uses the following terraform [providers](provider.tf), which must be ensured by the root module:
 - `SAP/btp`
 - `hashicorp/http`
 - `salrashid123/http-full`

### Outputs 

| Name                | Description                                                                                                                |
|---------------------|----------------------------------------------------------------------------------------------------------------------------|
| kubeconfig          | yaml-encoded parts of the output kubeconfig. It can be used to initialise terraform kubernetes provider in the root module |
| subaccount_id       | subaccount ID of the created subaccount. It can be used to forcefully cleanup the subaccount i.e via BTP CLI               |
| service_instance_id | service instance of the created Kyma environment                                                                           |
| cluster_id          | cluster ID of the created Kyma environment                                                                                 |
| domain              | domain of the created Kyma environment                                                                                     |


## How to Use the Terraform Module for Kyma

> [!NOTE]
> See the included [usage examples](./examples/).

1. To use the module, create a dedicated folder in your project repository (for example, `tf`), a main Terraform (`main.tf`) file, and `.tfvars` files. This will become the so-called root Terraform module, where the module for Kyma can be used as a child module.

> [!NOTE] 
> To learn more about Terraform modules, see [Modules](https://developer.hashicorp.com/terraform/language/modules)

```
.
+-- tf
|   +-- main.tf
|   +-- .tfvars
```

2. In the `.tfvars` file, provide values that are necessary for the `kyma` child module (kyma module's [input parameters](#input-variables-tf-vars)) and the `sap/btp` provider.

For example:
```tf
BTP_BOT_USER = "..."
BTP_BOT_PASSWORD = "..."
BTP_GLOBAL_ACCOUNT = "..."
BTP_BACKEND_URL = "https://cpcli.cf.sap.hana.ondemand.com"
BTP_CUSTOM_IAS_TENANT = "my-tenant"
BTP_NEW_SUBACCOUNT_NAME = "kyma-runtime-subaccount"
BTP_NEW_SUBACCOUNT_REGION = "eu21"
BTP_KYMA_PLAN = "azure"
BTP_KYMA_REGION = "westeurope"
```

3. In the `main.tf`, ensure the [required providers](#required-providers) and include the Kyma module as a child module.

```tf
terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
    }
    http = {
      source = "hashicorp/http"
    }
    http-full = {
      source = "salrashid123/http-full"
    }
  }
}

provider "http" {}
provider "http-full" {}
provider "btp" {
  globalaccount = var.BTP_GLOBAL_ACCOUNT
  cli_server_url = var.BTP_BACKEND_URL
  idp            = var.BTP_CUSTOM_IAS_TENANT
  username = var.BTP_BOT_USER
  password = var.BTP_BOT_PASSWORD
}

module "kyma" {
  source = "git::https://github.com/kyma-project/terraform-module.git?ref=v0.3.1"
  BTP_KYMA_PLAN = var.BTP_KYMA_PLAN
  BTP_KYMA_REGION = var.BTP_KYMA_REGION
  BTP_NEW_SUBACCOUNT_NAME = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_NEW_SUBACCOUNT_REGION = var.BTP_NEW_SUBACCOUNT_REGION
}

//Use the outputs of the Kyma module as you wish.
//Here it is forwarded as outputs of the root module.
output "subaccount_id" {
  value = module.kyma.subaccount_id
}

output "service_instance_id" {
  value = module.kyma.service_instance_id
}

output "cluster_id" {
  value = module.kyma.cluster_id
}

output "domain" {
  value = module.kyma.domain
}


```

4. Run the Terraform CLI in your root module's folder.

```bash
cd tf
terraform init
terraform apply -var-file=.tfvars -auto-approve 
```

You should see a new `kubeconfig.yaml` file in the root module folder, providing you access to the newly created Kyma runtime.

```
.
+-- tf
|   +-- main.tf
|   +-- .tfvars
|   +-- kubeconfig.yaml
```

* To read the output value, use the `terraform output` command, for example:

```bash
terraform output -raw cluster_id
```

To destroy all resources, call the destroy command:

```bash
terraform destroy -var-file=.tfvars -auto-approve        
```



