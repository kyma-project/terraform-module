# Terraform Module for Kyma on SAP BTP

## Status

[![REUSE status](https://api.reuse.software/badge/github.com/kyma-project/terraform-module)](https://api.reuse.software/info/github.com/kyma-project/terraform-module)

## Overview

Terraform module that creates Kyma runtime in SAP BTP platform. This includes the creation of the following resources:

- A new subaccount on SAP BTP (optional if `BTP_USE_SUBACCOUNT_ID` is not set)
- Entitlements on subaccount level for the following services:
  - cis
  - Kyma runtime
  - Service Manager Operator
- Service instances will be created for the following services:
  - cis (plan local)
- Environment binding for the Kyma runtime

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_btp"></a> [btp](#requirement\_btp) | >= 1.6.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.4.5 |
| <a name="requirement_terracurl"></a> [terracurl](#requirement\_terracurl) | >= 1.2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_btp"></a> [btp](#provider\_btp) | 1.14.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.3 |
| <a name="provider_terracurl"></a> [terracurl](#provider\_terracurl) | 1.2.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [btp_subaccount.subaccount](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount) | resource |
| [btp_subaccount_entitlement.cis](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_entitlement) | resource |
| [btp_subaccount_entitlement.kyma](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_entitlement) | resource |
| [btp_subaccount_entitlement.sm_operator_access](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_entitlement) | resource |
| [btp_subaccount_environment_instance.kyma](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_environment_instance) | resource |
| [btp_subaccount_service_binding.cis_local_binding](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_service_binding) | resource |
| [btp_subaccount_service_instance.cis_local](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_service_instance) | resource |
| [local_sensitive_file.ca_cert](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.kubeconfig_yaml](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [terracurl_request.cis_kyma_env_binding](https://registry.terraform.io/providers/devops-rob/terracurl/latest/docs/resources/request) | resource |
| [terraform_data.ca_cert](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.kubeconfig](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [btp_subaccount.reuse_subaccount](https://registry.terraform.io/providers/SAP/btp/latest/docs/data-sources/subaccount) | data source |
| [btp_subaccount_service_plan.cis](https://registry.terraform.io/providers/SAP/btp/latest/docs/data-sources/subaccount_service_plan) | data source |
| [http_http.cis_api_token](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_BTP_KYMA_AUTOSCALER_MAX"></a> [BTP\_KYMA\_AUTOSCALER\_MAX](#input\_BTP\_KYMA\_AUTOSCALER\_MAX) | Maximum number of virtual machines created in the Kyma environment. | `number` | `10` | no |
| <a name="input_BTP_KYMA_AUTOSCALER_MIN"></a> [BTP\_KYMA\_AUTOSCALER\_MIN](#input\_BTP\_KYMA\_AUTOSCALER\_MIN) | Minimum number of virtual machines created in the Kyma environment. | `number` | `3` | no |
| <a name="input_BTP_KYMA_CUSTOM_ADMINISTRATORS"></a> [BTP\_KYMA\_CUSTOM\_ADMINISTRATORS](#input\_BTP\_KYMA\_CUSTOM\_ADMINISTRATORS) | List of cluster administrators (list of email addresses) for the Kyma environment. | `list(string)` | `[]` | no |
| <a name="input_BTP_KYMA_CUSTOM_OIDC"></a> [BTP\_KYMA\_CUSTOM\_OIDC](#input\_BTP\_KYMA\_CUSTOM\_OIDC) | Custom OIDC configuration for the Kyma environment. | <pre>object({<br/>    clientID       = string<br/>    issuerURL      = string<br/>    usernameClaim  = string<br/>    usernamePrefix = string<br/>    groupsClaim    = string<br/>    signingAlgs    = list(string)<br/>    requiredClaims = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_BTP_KYMA_MODULES"></a> [BTP\_KYMA\_MODULES](#input\_BTP\_KYMA\_MODULES) | List of Kyma modules to install. You can specify the name and channel for each module. | <pre>list(object({<br/>    name    = string<br/>    channel = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "channel": "regular",<br/>    "name": "istio"<br/>  },<br/>  {<br/>    "channel": "regular",<br/>    "name": "api-gateway"<br/>  },<br/>  {<br/>    "channel": "regular",<br/>    "name": "btp-operator"<br/>  }<br/>]</pre> | no |
| <a name="input_BTP_KYMA_PLAN"></a> [BTP\_KYMA\_PLAN](#input\_BTP\_KYMA\_PLAN) | Plan name of the Kyma environment. | `string` | `"azure"` | no |
| <a name="input_BTP_KYMA_REGION"></a> [BTP\_KYMA\_REGION](#input\_BTP\_KYMA\_REGION) | Region of your Kyma Cluster | `string` | `"westeurope"` | no |
| <a name="input_BTP_KYMA_SETUP_TIMEOUTS"></a> [BTP\_KYMA\_SETUP\_TIMEOUTS](#input\_BTP\_KYMA\_SETUP\_TIMEOUTS) | Timeouts for the Kyma environment setup. | `map(string)` | <pre>{<br/>  "create": "60m",<br/>  "delete": "60m",<br/>  "update": "30m"<br/>}</pre> | no |
| <a name="input_BTP_NEW_SUBACCOUNT_NAME"></a> [BTP\_NEW\_SUBACCOUNT\_NAME](#input\_BTP\_NEW\_SUBACCOUNT\_NAME) | Name of the new subaccount for the Kyma cluster | `string` | `null` | no |
| <a name="input_BTP_NEW_SUBACCOUNT_REGION"></a> [BTP\_NEW\_SUBACCOUNT\_REGION](#input\_BTP\_NEW\_SUBACCOUNT\_REGION) | Region for the subaccount where the Kyma environment is created | `string` | `"eu20"` | no |
| <a name="input_BTP_USE_SUBACCOUNT_ID"></a> [BTP\_USE\_SUBACCOUNT\_ID](#input\_BTP\_USE\_SUBACCOUNT\_ID) | ID of the subaccount to be used for the Kyma cluster | `string` | `null` | no |
| <a name="input_store_cacert_locally"></a> [store\_cacert\_locally](#input\_store\_cacert\_locally) | If true, the ca certificate will be stored in a local file named 'CA.crt'. | `bool` | `false` | no |
| <a name="input_store_kubeconfig_locally"></a> [store\_kubeconfig\_locally](#input\_store\_kubeconfig\_locally) | If true, the kubeconfig will be stored in a local file named 'kubeconfig.yaml'. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apiserver_url"></a> [apiserver\_url](#output\_apiserver\_url) | The API server URL of the Kyma cluster. |
| <a name="output_environment_instance_id"></a> [environment\_instance\_id](#output\_environment\_instance\_id) | The ID of the Kyma environment instance. |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig for the Kyma environment. |
| <a name="output_subaccount_id"></a> [subaccount\_id](#output\_subaccount\_id) | The ID of the subaccount where the Kyma environment is created. |

## How to Use the Terraform Module for Kyma

> [!NOTE]
> You find several samples in the [usage examples](./examples/) folder.

1. To use the module, create a dedicated folder in your project repository (for example, `tf`), a main Terraform (`main.tf`) file, and `terraform.tfvars` files. The structure then looks like this:

```bash
+-- tf
|   +-- main.tf
|   +-- terraform.tfvars
```

2. In the `terraform.tfvars` file, provide values that are necessary for the `Kyma` module (Kyma module's [input parameters](#inputs)) and the [Terrform provider for SAP BTP](https://registry.terraform.io/providers/SAP/btp/latest) that is used in the module.

For example:

```terraform
BTP_BOT_USER              = "..."
BTP_BOT_PASSWORD          = "..."
BTP_GLOBAL_ACCOUNT        = "..."
BTP_CUSTOM_IAS_TENANT     = "my-tenant"
BTP_NEW_SUBACCOUNT_NAME   = "kyma-runtime-subaccount"
BTP_NEW_SUBACCOUNT_REGION = "eu21"
BTP_KYMA_PLAN             = "azure"
BTP_KYMA_REGION           = "westeurope"
```

3. In the `main.tf`, ensure the [required providers](#providers) and include the Kyma module as a child module.

```terraform
terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.14.0"
    }
     terracurl = {
      source  = "devops-rob/terracurl"
      version = "~> 1.2.2"
    }
  }
}

provider "btp" {
  globalaccount  = var.BTP_GLOBAL_ACCOUNT
  idp            = var.BTP_CUSTOM_IAS_TENANT
  username       = var.BTP_BOT_USER
  password       = var.BTP_BOT_PASSWORD
}

provider "terracurl" {}

module "kyma" {
  source                    = "git::https://github.com/kyma-project/terraform-module.git?ref=v0.4.1"
  BTP_KYMA_PLAN             = var.BTP_KYMA_PLAN
  BTP_KYMA_REGION           = var.BTP_KYMA_REGION
  BTP_NEW_SUBACCOUNT_NAME   = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_NEW_SUBACCOUNT_REGION = var.BTP_NEW_SUBACCOUNT_REGION
}

output "subaccount_id" {
  description = "The subaccount ID where the Kyma environment is created."
  value = module.kyma.subaccount_id
}

output "environment_instance_id" {
  description = "The Kyma environment instance ID."
  value = module.kyma.environment_instance_id
}

output "apiserver_url" {
  description = "The API server URL of the Kyma cluster."
  value       = module.kyma.apiserver_url
}
```

4. Run the Terraform CLI in the `tf` folder.

```bash
cd tf
terraform init
terraform apply
```

Validate that the planned changes are correct, and then confirm the `apply` operation. This will create a new Kyma runtime in your SAP BTP account.

* To read the output value, use the `terraform output` command, for example:

```bash
terraform output apiserver_url
```

To destroy all resources, call the destroy command:

```bash
terraform destroy
```

Validate that the planned changes are correct, and then confirm the `destroy` operation.

## Local execution of the module

For a local usage of the module, we added the parameters `store_kubeconfig_locally` and `store_ca_cert_locally` to the module. If you set these parameters to `true`, the module will create a local file with the kubeconfig and CA certificate of the Kyma cluster. This adds some convenience for local development and testing.

As a next step you might want to extract the Kyma Cluster ID as well as the Kyma Cluster domain. This operation cannot be directly done inside of the module without having several drawbacks when it comes to the Terraform lifecycle. To enable the retirval of these values we added a Bash and a Powershell script to the GitHub repository in the folder [scripts](https://github.com/kyma-project/terraform-module/tree/main/scripts) that you can use to extract these values from the Kyma cluster. The scripts will read the kubeconfig file from the environment variable `KUBECONFIG` and extract the cluster ID and domain and write them to local files called `domain.txt` and `cluster_id.txt`.
