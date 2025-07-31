terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.14.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "~> 1.2.2"
    }
  }
}

provider "btp" {
  globalaccount  = var.BTP_GLOBAL_ACCOUNT
  cli_server_url = var.BTP_BACKEND_URL
  idp            = var.BTP_CUSTOM_IAS_TENANT
  username       = var.BTP_BOT_USER
  password       = var.BTP_BOT_PASSWORD
}

provider "terracurl" {}

module "kyma" {
  source = "git::https://github.com/kyma-project/terraform-btp-kyma-environment.git?ref=1.0.0"

  BTP_NEW_SUBACCOUNT_NAME        = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_NEW_SUBACCOUNT_REGION      = var.BTP_NEW_SUBACCOUNT_REGION
  BTP_KYMA_PLAN                  = var.BTP_KYMA_PLAN
  BTP_KYMA_REGION                = var.BTP_KYMA_REGION
  BTP_KYMA_MODULES               = jsondecode(var.BTP_KYMA_MODULES_STRINGIFIED)
  BTP_KYMA_AUTOSCALER_MIN        = var.BTP_KYMA_AUTOSCALER_MIN
  BTP_KYMA_CUSTOM_ADMINISTRATORS = jsondecode(var.BTP_KYMA_CUSTOM_ADMINISTRATORS)
  store_kubeconfig_locally       = true
}

output "subaccount_id" {
  value = module.kyma.subaccount_id
}

