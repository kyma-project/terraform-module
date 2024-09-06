terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "1.5.0"
    }
    jq = {
      source  = "massdriver-cloud/jq"
    }
    http = {
      source = "hashicorp/http"
      version = "3.4.4"
    }
  }
}


provider "jq" {}
provider "http" {}

provider "btp" {
  globalaccount = var.BTP_GLOBAL_ACCOUNT
  cli_server_url = var.BTP_BACKEND_URL
  idp            = var.BTP_CUSTOM_IAS_TENANT
  username = var.BTP_BOT_USER
  password = var.BTP_BOT_PASSWORD
}

module "kyma" {
  source = "../.."
  BTP_KYMA_PLAN = var.BTP_KYMA_PLAN
  BTP_NEW_SUBACCOUNT_NAME = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_CUSTOM_IAS_TENANT = var.BTP_CUSTOM_IAS_TENANT
  BTP_CUSTOM_IAS_DOMAIN = var.BTP_CUSTOM_IAS_DOMAIN
  BTP_KYMA_REGION = var.BTP_KYMA_REGION
  BTP_BOT_USER = var.BTP_BOT_USER
  BTP_BOT_PASSWORD = var.BTP_BOT_PASSWORD
  BTP_PROVIDER_SUBACCOUNT_ID = var.BTP_PROVIDER_SUBACCOUNT_ID
  BTP_NEW_SUBACCOUNT_REGION = var.BTP_NEW_SUBACCOUNT_REGION
}