# Prerequisites

## Ensure CLI tools

Ensure you have opentofu (or terraform CLI installed).
The sample scripts relly on `tofu` command, but its 100% compatible with `terraform` CLI.

Ensure the tofu CLI is installed by calling:
```sh
brew install opentofu
```

## Ensure bot user access

In order to make automatic management of btp resources possible you need to ensure the following:
 - establish trust between BTP global account and your custom IAS tenant
 - add the bot user to the custom IAS tenant
 - assign global account administrator role collection to the bot user (this example needs it to create subaccount. It is not required if subaccount is reused)
 - if you decide to use provider subaccount in order to create disposable references to existing, shared instances of stateful services  (via `BTP_PROVIDER_SUBACCOUNT_ID` environment variable ) the bot user would need to have `Subaccount Viewer` role collection assigned in the provider subaccount.

## Ensure Input Variables

Save a new version of the template file `examples/kyma-on-btp-basic/local-template.tfvars` as `examples/kyma-on-btp-basic/local.tfvars`. Provide values for input variables


# Run 


Run the example:

```sh
tofu init
tofu apply -var="BTP_SUBACCOUNT=foo" -var-file="local.tfvars" -auto-approve
```

As a result, a new `kubeconfig.yaml` file was created that you can use to access the newly provisioned kyma runtime on SAP BTP.

```sh
kubectl get nodes --kubeconfig kubeconfig.yaml
```

Last but not least, deprovision all resources via:

```sh
tofu destroy -var="BTP_SUBACCOUNT=foo" -var-file="local.tfvars" -auto-approve
```