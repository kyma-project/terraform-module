module "kyma" {
  # Replace with version you want to use - avoid using latest as version constraint
  source = "git::https://github.com/kyma-project/terraform-btp-kyma-environment.git?ref=latest"

  BTP_NEW_SUBACCOUNT_NAME        = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_NEW_SUBACCOUNT_REGION      = var.BTP_NEW_SUBACCOUNT_REGION
  BTP_KYMA_PLAN                  = var.BTP_KYMA_PLAN
  BTP_KYMA_REGION                = var.BTP_KYMA_REGION
  BTP_KYMA_CUSTOM_ADMINISTRATORS = var.BTP_KYMA_CUSTOM_ADMINISTRATORS
  BTP_KYMA_AUTOSCALER_MIN        = 3
  BTP_KYMA_AUTOSCALER_MAX        = 4
}
