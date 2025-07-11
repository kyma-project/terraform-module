module "kyma" {
  source = "git::https://github.com/kyma-project/terraform-module.git?ref=v0.4.1"

  BTP_KYMA_PLAN                  = var.BTP_KYMA_PLAN
  BTP_NEW_SUBACCOUNT_NAME        = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_KYMA_REGION                = var.BTP_KYMA_REGION
  BTP_NEW_SUBACCOUNT_REGION      = var.BTP_NEW_SUBACCOUNT_REGION
  BTP_KYMA_MODULES               = []
  BTP_KYMA_CUSTOM_ADMINISTRATORS = var.BTP_KYMA_CUSTOM_ADMINISTRATORS
  BTP_KYMA_AUTOSCALER_MIN        = 3
  BTP_KYMA_AUTOSCALER_MAX        = 4
}
