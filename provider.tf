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
      version = "3.4.5"
    }
    http-full = {
      source = "salrashid123/http-full"
    }   
  }
}
