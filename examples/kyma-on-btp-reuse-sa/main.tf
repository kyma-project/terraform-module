terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
    }
    jq = {
      source  = "massdriver-cloud/jq"
    }
    http = {
      source = "hashicorp/http"
    }
    http-full = {
      source = "salrashid123/http-full"
    }
  }
}


provider "jq" {}
provider "http" {}
provider "http-full" {}

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
  BTP_KYMA_REGION = var.BTP_KYMA_REGION
  BTP_USE_SUBACCOUNT_ID = var.BTP_USE_SUBACCOUNT_ID
}

output "service_instance_id" {
  value = module.kyma.service_instance_id
}

output "cluster_id" {
  value = module.kyma.cluster_id
}

output "domain" {
  value = module.kyma.domain
}