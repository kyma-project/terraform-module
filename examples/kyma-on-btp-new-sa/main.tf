terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = ">= 1.6.0"
    }
    http = {
      source = "hashicorp/http"
    }
    http-full = {
      source = "salrashid123/http-full"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.1"
    }   
  }
}


provider "http" {}
provider "http-full" {}

provider "btp" {
  globalaccount = var.BTP_GLOBAL_ACCOUNT
  cli_server_url = var.BTP_BACKEND_URL
  idp            = var.BTP_CUSTOM_IAS_TENANT
  username = var.BTP_BOT_USER
  password = var.BTP_BOT_PASSWORD
}

# this shows how to configure kubernetes terraform provider with the output from terraform module for kyma
locals {
  kubeconfig = module.kyma.kubeconfig
}

provider "kubernetes" {
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters.0.cluster.certificate-authority-data)
  host                   = local.kubeconfig.clusters.0.cluster.server
  token                  = local.kubeconfig.users.0.user.token
}

module "kyma" {
  source = "../.."
  BTP_KYMA_PLAN = var.BTP_KYMA_PLAN
  BTP_NEW_SUBACCOUNT_NAME = var.BTP_NEW_SUBACCOUNT_NAME
  BTP_KYMA_REGION = var.BTP_KYMA_REGION
  BTP_NEW_SUBACCOUNT_REGION = var.BTP_NEW_SUBACCOUNT_REGION
  BTP_KYMA_MODULES = []
  BTP_KYMA_CUSTOM_ADMINISTRATORS = var.BTP_KYMA_CUSTOM_ADMINISTRATORS
  BTP_KYMA_AUTOSCALER_MIN = 3
  BTP_KYMA_AUTOSCALER_MAX = 4
}

output "subaccount_id" {
  value = module.kyma.subaccount_id
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

output "apiserver_url" {
  value = module.kyma.apiserver_url
}

# this shows how to use kubernetes terraform provider to read data from k8s cluster
data "kubernetes_namespace" "default" {
  depends_on = [
    module.kyma.kubeconfig
  ]
  metadata {
    name = "default"
  }
}