# terraform-sap-kyma-on-btp

## Status

[![REUSE status](https://api.reuse.software/badge/github.com/kyma-project/terraform-module)](https://api.reuse.software/info/github.com/kyma-project/terraform-module)

## Overview

Terraform module that creates kyma runtime in SAP BTP platform.

![image](./assets/sequence.png)

### Input Variables (TF vars)

| NAME                       | MANDATORY | DEFAULT VALUE             | DESCRIPTION                                                                                                                                        |
|----------------------------|-----------|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| BTP_GLOBAL_ACCOUNT         | true      |                           | UUID of SAP BTP Global Account                                                                                                                     |
| BTP_BOT_USER               | true      |                           | Email of the technical user (shared mailbox)                                                                                                       |
| BTP_BOT_PASSWORD           | true      |                           | Password of the techniacal user (created when inviting shared mailbox into custom SAP IAS tenant)                                                  |
| BTP_USE_SUBACCOUNT_ID      | false     |                           | Provide an UUID of existing SAP BTP Subaccount to be used. Should not be combined with `BTP_NEW_SUBACCOUNT_*` inputs.                              |
| BTP_NEW_SUBACCOUNT_NAME    | false     |                           | Provide a name for a new SAP BTP Subaccount to be created. Should not be combined with  `BTP_USE_SUBACCOUNT_ID` input.                             |
| BTP_NEW_SUBACCOUNT_REGION  | false     |                           | Provide a region for a new SAP BTP Subaccount to be created. Should not be combined with  `BTP_USE_SUBACCOUNT_ID` input.                           |
| BTP_CUSTOM_IAS_TENANT      | true      |                           | Provide the name of the custom SAP IAS tenant that is an authentication provider for the technical user.                                           |
| BTP_CUSTOM_IAS_DOMAIN      | false     | accounts.ondemand.com     | Domain of the identity provider (on canary and staging environments this has to be set to `accounts400.ondemand.com`)                              |
| BTP_BACKEND_URL            | false     | https://cli.btp.cloud.sap | URL of the BTP backend API (on canary environment this has to be set to  `https://cpcli.cf.sap.hana.ondemand.com`).                                |
| BTP_KYMA_PLAN              | false     | azure                     | Use one of a valid kyma plans that you are entitled to use (One of: `azure`, `gcp`, `aws`,`sap-converged-cloud`)                                   |
| BTP_KYMA_REGION            | false     | westeurope                | Use a valid kyma region that matches your selected kyma plan                                                                                       |

### Required Providers

Terraform module for Kyma uses the following terraform [providers](provider.tf), which must be ensured by the root module:
 - `SAP/btp`
 - `massdriver-cloud/jq`
 - `hashicorp/http`

### Outputs 

| Name                | Description                                                                                                                |
|---------------------|----------------------------------------------------------------------------------------------------------------------------|
| kubeconfig          | yaml-encoded parts of the output kubeconfig. It can be used to initialise terraform kubernetes provider in the root module |
| subaccount_id       | subaccount ID of the created subaccount. It can be used to forcefully cleanup the subaccount i.e via BTP CLI               |
| service_instance_id | service instance of the created Kyma environment                                                                           |
| cluster_id          | cluster ID of the created Kyma environment                                                                                 |
| domain              | domain of the created Kyma environment                                                                                     |

## Running `terraform-sap-kyma-on-btp` module


The module should be included as a child module, and provided with a configured `sap/btp` terraform provider. The root module must define the values for the input variables. Go to the included [examples](./examples/).

