terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.14.0"
    }
    http-full = {
      source  = "salrashid123/http-full"
      version = "~> 1.3.1"
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

provider "http-full" {}
