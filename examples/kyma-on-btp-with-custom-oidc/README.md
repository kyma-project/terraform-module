# Sample configuration for Kyma environment on SAP BTP inside an existing subaccount with a custom OIDC provider

This sample configuration showcases the creation of a Kyma environment in an existing subaccount on SAP BTP including the setup with a custom OIDC provider.

## Usage

Before running the example make sure that you provided the necessary parameters in a `terraform.tfvars` file. A sample `terraform.tfvars.example` file is provided in this directory.

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan -out=plan.out
$ terraform apply plan.out
```

To destroy this example you can execute:

```bash
$ terraform destroy
```

Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_btp"></a> [btp](#requirement\_btp) | ~> 1.14.0 |
| <a name="requirement_terracurl"></a> [terracurl](#requirement\_terracurl) | ~> 1.2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_btp"></a> [btp](#provider\_btp) | ~> 1.14.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kyma"></a> [kyma](#module\_kyma) | git::https://github.com/kyma-project/terraform-btp-kyma-environment.git | latest |

## Resources

| Name | Type |
|------|------|
| [btp_subaccount_entitlement.identity](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_entitlement) | resource |
| [btp_subaccount_service_binding.identity_application_binding](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_service_binding) | resource |
| [btp_subaccount_service_instance.identity_application](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_service_instance) | resource |
| [btp_subaccount_trust_configuration.custom_idp](https://registry.terraform.io/providers/SAP/btp/latest/docs/resources/subaccount_trust_configuration) | resource |
| [btp_subaccount.target_subaccount](https://registry.terraform.io/providers/SAP/btp/latest/docs/data-sources/subaccount) | data source |
| [btp_subaccount_service_plan.identity_application](https://registry.terraform.io/providers/SAP/btp/latest/docs/data-sources/subaccount_service_plan) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_BTP_BACKEND_URL"></a> [BTP\_BACKEND\_URL](#input\_BTP\_BACKEND\_URL) | BTP backend URL | `string` | `"https://cli.btp.cloud.sap"` | no |
| <a name="input_BTP_BOT_PASSWORD"></a> [BTP\_BOT\_PASSWORD](#input\_BTP\_BOT\_PASSWORD) | Bot account password | `string` | n/a | yes |
| <a name="input_BTP_BOT_USER"></a> [BTP\_BOT\_USER](#input\_BTP\_BOT\_USER) | Bot account name | `string` | n/a | yes |
| <a name="input_BTP_CUSTOM_IAS_DOMAIN"></a> [BTP\_CUSTOM\_IAS\_DOMAIN](#input\_BTP\_CUSTOM\_IAS\_DOMAIN) | Custom IAS domain | `string` | `"accounts.ondemand.com"` | no |
| <a name="input_BTP_CUSTOM_IAS_TENANT"></a> [BTP\_CUSTOM\_IAS\_TENANT](#input\_BTP\_CUSTOM\_IAS\_TENANT) | Custom IAS tenant | `string` | `"custom-tenant"` | no |
| <a name="input_BTP_GLOBAL_ACCOUNT"></a> [BTP\_GLOBAL\_ACCOUNT](#input\_BTP\_GLOBAL\_ACCOUNT) | Subdomain of the SAP BTP global account | `string` | n/a | yes |
| <a name="input_BTP_KYMA_CUSTOM_ADMINISTRATORS"></a> [BTP\_KYMA\_CUSTOM\_ADMINISTRATORS](#input\_BTP\_KYMA\_CUSTOM\_ADMINISTRATORS) | n/a | `list(string)` | `[]` | no |
| <a name="input_BTP_KYMA_PLAN"></a> [BTP\_KYMA\_PLAN](#input\_BTP\_KYMA\_PLAN) | Plan name | `string` | `"azure"` | no |
| <a name="input_BTP_KYMA_REGION"></a> [BTP\_KYMA\_REGION](#input\_BTP\_KYMA\_REGION) | Kyma region | `string` | `"westeurope"` | no |
| <a name="input_BTP_USE_SUBACCOUNT_ID"></a> [BTP\_USE\_SUBACCOUNT\_ID](#input\_BTP\_USE\_SUBACCOUNT\_ID) | ID of the subaccount | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apiserver_url"></a> [apiserver\_url](#output\_apiserver\_url) | API server URL of the Kyma cluster |
| <a name="output_environment_instance_id"></a> [environment\_instance\_id](#output\_environment\_instance\_id) | Id of the Kyma environment instance |
| <a name="output_subaccount_id"></a> [subaccount\_id](#output\_subaccount\_id) | ID of the subaccount on SAP BTP |
