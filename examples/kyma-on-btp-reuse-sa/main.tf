module "kyma" {
  source = "git::https://github.com/kyma-project/terraform-module.git?ref=v0.4.1"

  BTP_KYMA_PLAN         = var.BTP_KYMA_PLAN
  BTP_KYMA_REGION       = var.BTP_KYMA_REGION
  BTP_USE_SUBACCOUNT_ID = var.BTP_USE_SUBACCOUNT_ID
}
