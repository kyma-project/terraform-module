# Run 

Save a new version of the template file `examples/kyma-on-btp-basic/local-template.tfvars` as `examples/kyma-on-btp-basic/local.tfvars`. Provide values for input variables.

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