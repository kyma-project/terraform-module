terraform {
  # Due to cross variable validation, we must set the required version to 1.9 or higher
  required_version = ">= 1.9.0"
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = ">= 1.6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.5"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = ">= 1.2.2"
    }
  }
}
