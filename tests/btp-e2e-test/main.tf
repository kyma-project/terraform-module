module "kyma" {
  source = "../.."

  BTP_NEW_SUBACCOUNT_NAME   = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_NEW_SUBACCOUNT_REGION = var.BTP_NEW_SUBACCOUNT_REGION
  BTP_KYMA_PLAN             = var.BTP_KYMA_PLAN
  BTP_KYMA_REGION           = var.BTP_KYMA_REGION
  BTP_KYMA_AUTOSCALER_MIN   = 3
  BTP_KYMA_AUTOSCALER_MAX   = 4
  store_kubeconfig_locally  = true
  store_cacert_locally      = true
}
