module "kyma" {
  # Replace with version you want to use - avoid using main as version constraint
  source = "git::https://github.com/kyma-project/terraform-btp-kyma-environment.git?ref=1.0.0"

  BTP_USE_SUBACCOUNT_ID          = var.BTP_USE_SUBACCOUNT_ID
  BTP_KYMA_PLAN                  = var.BTP_KYMA_PLAN
  BTP_KYMA_REGION                = var.BTP_KYMA_REGION
  BTP_KYMA_CUSTOM_ADMINISTRATORS = var.BTP_KYMA_CUSTOM_ADMINISTRATORS
  BTP_KYMA_AUTOSCALER_MIN        = 3
  BTP_KYMA_AUTOSCALER_MAX        = 4
}
