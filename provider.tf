terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = ">= 1.6.0"
    }
    http = {
      source = "hashicorp/http"
      version = ">= 3.4.5"
    }
    http-full = {
      source = "salrashid123/http-full"
    }   
  }
}
