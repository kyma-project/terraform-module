## Prerequisites

### Ensure CLI tools
Ensure you have opentofu (or terraform CLI installed).
The sample scripts relly on `tofu` command, but its 100% compatible with `terraform` CLI.

Ensure the tofu CLI is installed by calling:
```sh
brew install opentofu
```

### Ensure Input parameters 

Save a new version of the template file `examples/kyma-on-btp-with-custom-oidc/local-template.tfvars` as `examples/kyma-on-btp-with-custom-oidc/local.tfvars`. Provide values for input variables.

```
BTP_NEW_SUBACCOUNT_NAME = "new-test-sa"
BTP_NEW_SUBACCOUNT_REGION = "..."
BTP_BOT_USER = "{my-technical-user}@sap.com"
BTP_BOT_PASSWORD = "..."
BTP_GLOBAL_ACCOUNT = "..."
BTP_CUSTOM_IAS_TENANT = "..."
```

### Ensure technical user access

In this example a new subaccount is created automatically. Please ensure the following
 - make sure that your custom SAP IAS tenant is trusted on global account level,
 - make sure that technical user (bot user) is added to the global account and is assigned a global account administrator role collection,
 - make sure the technical user is added to your custom SAP IAS tenant. 
 
## Run 
Run the example:

```sh
tofu init
tofu apply -var-file="local.tfvars" -auto-approve
```

As a result, a new `kubeconfig.yaml` file was created that you can use to access the newly provisioned kyma runtime on SAP BTP.

```sh
kubectl get nodes --kubeconfig kubeconfig.yaml
```

Last but not least, deprovision all resources via:

```sh
tofu destroy -var-file="local.tfvars" -auto-approve
```