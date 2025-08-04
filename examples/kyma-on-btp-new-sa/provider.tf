terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~> 1.15.1"
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
