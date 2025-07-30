# Sample configuration for Kyma environment on SAP BTP inside an existing subaccount

This sample configuration showcases the creation of a Kyma environment in an existing subaccount on SAP BTP.

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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kyma"></a> [kyma](#module\_kyma) | git::https://github.com/kyma-project/terraform-btp-kyma-environment.git | latest |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_BTP_BACKEND_URL"></a> [BTP\_BACKEND\_URL](#input\_BTP\_BACKEND\_URL) | BTP backend URL | `string` | `"https://cli.btp.cloud.sap"` | no |
| <a name="input_BTP_BOT_PASSWORD"></a> [BTP\_BOT\_PASSWORD](#input\_BTP\_BOT\_PASSWORD) | Bot account password | `string` | n/a | yes |
| <a name="input_BTP_BOT_USER"></a> [BTP\_BOT\_USER](#input\_BTP\_BOT\_USER) | Bot account name | `string` | n/a | yes |
| <a name="input_BTP_CUSTOM_IAS_TENANT"></a> [BTP\_CUSTOM\_IAS\_TENANT](#input\_BTP\_CUSTOM\_IAS\_TENANT) | Custom IAS tenant | `string` | `"custon-tenant"` | no |
| <a name="input_BTP_GLOBAL_ACCOUNT"></a> [BTP\_GLOBAL\_ACCOUNT](#input\_BTP\_GLOBAL\_ACCOUNT) | Subdomain of the SAP BTP global account | `string` | n/a | yes |
| <a name="input_BTP_KYMA_CUSTOM_ADMINISTRATORS"></a> [BTP\_KYMA\_CUSTOM\_ADMINISTRATORS](#input\_BTP\_KYMA\_CUSTOM\_ADMINISTRATORS) | n/a | `list(string)` | `[]` | no |
| <a name="input_BTP_KYMA_PLAN"></a> [BTP\_KYMA\_PLAN](#input\_BTP\_KYMA\_PLAN) | Plan name | `string` | `"azure"` | no |
| <a name="input_BTP_KYMA_REGION"></a> [BTP\_KYMA\_REGION](#input\_BTP\_KYMA\_REGION) | Kyma region | `string` | `"westeurope"` | no |
| <a name="input_BTP_USE_SUBACCOUNT_ID"></a> [BTP\_USE\_SUBACCOUNT\_ID](#input\_BTP\_USE\_SUBACCOUNT\_ID) | ID of the subaccount to be reused | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the Kyma cluster |
| <a name="output_domain"></a> [domain](#output\_domain) | Domain of the Kyma cluster |
| <a name="output_environment_instance_id"></a> [environment\_instance\_id](#output\_environment\_instance\_id) | ID of the Kyma environment instance |
