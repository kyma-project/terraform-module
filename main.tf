# "kyma.tf"

locals {
  subaccount_name = var.BTP_USE_SUBACCOUNT_ID != null && var.BTP_NEW_SUBACCOUNT_NAME ==null ? one(data.btp_subaccount.reuse_subaccount).name : one(btp_subaccount.subaccount).name
  subaccount_id   = var.BTP_USE_SUBACCOUNT_ID != null && var.BTP_NEW_SUBACCOUNT_NAME ==null ? one(data.btp_subaccount.reuse_subaccount).id : one(btp_subaccount.subaccount).id
}

resource "btp_subaccount_entitlement" "kyma" {
  subaccount_id = local.subaccount_id
  service_name  = "kymaruntime"
  plan_name     = var.BTP_KYMA_PLAN
  amount        = 1
}

resource "btp_subaccount_environment_instance" "kyma" {
  subaccount_id    = local.subaccount_id
  name             = "${local.subaccount_name}-kyma"
  environment_type = "kyma"
  service_name     = btp_subaccount_entitlement.kyma.service_name
  plan_name        = btp_subaccount_entitlement.kyma.plan_name
  parameters = jsonencode({
    modules = {
      list = var.BTP_KYMA_MODULES
    }
    oidc = {
      groupsClaim    = "groups"
      signingAlgs    = ["RS256"]
      usernameClaim  = "sub"
      usernamePrefix = "-"
      clientID       = jsondecode(btp_subaccount_service_binding.identity_application_binding.credentials).clientid
      issuerURL      = "https://${var.BTP_CUSTOM_IAS_TENANT}.${var.BTP_CUSTOM_IAS_DOMAIN}"
    }
    name   = "${local.subaccount_name}-kyma"
    region = var.BTP_KYMA_REGION
    administrators = [
      var.BTP_BOT_USER
    ]
  })
  timeouts = {
    create = "60m"
    update = "30m"
    delete = "60m"
  }
}


resource "local_sensitive_file" "kubeconfig-yaml" {
  filename = "kubeconfig.yaml"
  content  = jsondecode(data.http.kymaruntime_bindings.response_body).credentials.kubeconfig
}

# wait for kyma readiness 
resource "terraform_data" "wait-for-kyma-readiness" {
  depends_on = [
    resource.local_sensitive_file.kubeconfig-yaml
  ]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
     command = <<EOF
       (
      KUBECONFIG=kubeconfig.yaml
      set -e -o pipefail ;\
      curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
      chmod +x kubectl
      while ! kubectl get crd kymas.operator.kyma-project.io --kubeconfig $KUBECONFIG; do echo "Waiting for Kyma CRD..."; sleep 1; done
      kubectl wait --for condition=established crd/kymas.operator.kyma-project.io --kubeconfig $KUBECONFIG
      while ! kubectl get kyma default -n kyma-system --kubeconfig $KUBECONFIG; do echo "Waiting for default kyma CR..."; sleep 1; done
      kubectl wait --for='jsonpath={.status.state}=Ready' kymas.operator.kyma-project.io/default -n kyma-system --kubeconfig $KUBECONFIG --timeout=480s
      while ! kubectl get secret sap-btp-operator-clusterid -n kyma-system --kubeconfig $KUBECONFIG; do echo "Waiting for sap-btp-operator-clusterid..."; sleep 1; done
      kubectl get secret sap-btp-operator-clusterid -n kyma-system -ojsonpath={.data.INITIAL_CLUSTER_ID} --kubeconfig $KUBECONFIG > cluster_id.txt
      while ! kubectl get cm shoot-info -n kube-system --kubeconfig $KUBECONFIG; do echo "Waiting for shoot-info cm..."; sleep 1; done
      kubectl get cm shoot-info -n kube-system -ojsonpath={.data.domain} --kubeconfig $KUBECONFIG  > domain.txt
       )
     EOF
  } 
}

data "local_file" "cluster_id" {
  depends_on = [
    resource.terraform_data.wait-for-kyma-readiness
  ]
  filename = "cluster_id.txt"
}

data "local_file" "domain" {
  depends_on = [
    resource.terraform_data.wait-for-kyma-readiness
  ]
  filename = "domain.txt"
}

#"oidc.tf"
resource "btp_subaccount_entitlement" "identity" {
  subaccount_id = local.subaccount_id
  service_name  = "identity"
  plan_name     = "application"
}

# custom idp
resource "btp_subaccount_trust_configuration" "custom_idp" {
  subaccount_id     = local.subaccount_id
  identity_provider = "${var.BTP_CUSTOM_IAS_TENANT}.${var.BTP_CUSTOM_IAS_DOMAIN}"
  name              = "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}"
}

data "btp_subaccount_service_plan" "identity_application" {
  depends_on    = [btp_subaccount_entitlement.identity]
  subaccount_id = local.subaccount_id
  offering_name = "identity"
  name          = "application"
}

resource "btp_subaccount_service_instance" "identity_application" {
  depends_on     = [btp_subaccount_trust_configuration.custom_idp]
  subaccount_id  = local.subaccount_id
  name           = "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app"
  serviceplan_id = data.btp_subaccount_service_plan.identity_application.id
  parameters = jsonencode({
    user-access = "public"
    oauth2-configuration = {
      grant-types = [
        "authorization_code",
        "authorization_code_pkce_s256",
        "refresh_token"
      ],
      token-policy = {
        token-validity              = 3600,
        refresh-validity            = 15552000,
        refresh-usage-after-renewal = "off",
        refresh-parallel            = 3,
        access-token-format         = "default"
      },
      public-client = true,
      redirect-uris = [
        "https://dashboard.kyma.cloud.sap",
        "https://dashboard.dev.kyma.cloud.sap",
        "https://dashboard.stage.kyma.cloud.sap",
        "http://localhost:8000"
      ]
    },
    subject-name-identifier = {
      attribute          = "mail",
      fallback-attribute = "none"
    },
    default-attributes = null,
    assertion-attributes = {
      email      = "mail",
      groups     = "companyGroups",
      first_name = "firstName",
      last_name  = "lastName",
      login_name = "loginName",
      mail       = "mail",
      scope      = "companyGroups",
      user_uuid  = "userUuid",
      locale     = "language"
    },
    name         = "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app",
    display-name = "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app"
  })
}

resource "btp_subaccount_service_binding" "identity_application_binding" {
  subaccount_id       = local.subaccount_id
  name                =  "${local.subaccount_name}-${var.BTP_CUSTOM_IAS_TENANT}-oidc-app-binding"
  service_instance_id = btp_subaccount_service_instance.identity_application.id
  parameters = jsonencode({
    credential-type = "X509_GENERATED"
    key-length      = 4096
    validity        = 1
    validity-type   = "DAYS"
    app-identifier  = "kymaruntime"
  })
}

locals {
  idp = jsondecode(btp_subaccount_service_binding.identity_application_binding.credentials)
  cisCredentials = jsondecode(btp_subaccount_service_binding.cis-local-binding.credentials)
  instance_id = btp_subaccount_environment_instance.kyma.id
  cisBasicAuth = base64encode("${local.cisCredentials.uaa.clientid}:${local.cisCredentials.uaa.clientsecret}")
}


#"subaccount.tf"
data "btp_subaccount" "reuse_subaccount" {
  count = var.BTP_USE_SUBACCOUNT_ID != null && var.BTP_NEW_SUBACCOUNT_NAME == null ? 1 : 0
  id = var.BTP_USE_SUBACCOUNT_ID
}

resource "btp_subaccount" "subaccount" {
  count = var.BTP_NEW_SUBACCOUNT_NAME != null && var.BTP_USE_SUBACCOUNT_ID == null ? 1 : 0
  name      = var.BTP_NEW_SUBACCOUNT_NAME
  region    = var.BTP_NEW_SUBACCOUNT_REGION
  subdomain = var.BTP_NEW_SUBACCOUNT_NAME
}

# cis
resource "btp_subaccount_entitlement" "cis" {
  subaccount_id = local.subaccount_id
  service_name  = "cis"
  plan_name     = "local"
}

data "btp_subaccount_service_plan" "cis" {
  depends_on     = [btp_subaccount_entitlement.cis]
  subaccount_id = local.subaccount_id
  offering_name = "cis"
  name          = "local"
}

resource "btp_subaccount_service_instance" "cis-local" {
  depends_on     = [btp_subaccount_entitlement.cis]
  subaccount_id  = local.subaccount_id
  name           = "cis-local"
  serviceplan_id = data.btp_subaccount_service_plan.cis.id
  parameters = jsonencode({
      "grantType": "clientCredentials"
  })
}

resource "btp_subaccount_service_binding" "cis-local-binding" {
  depends_on          = [btp_subaccount_service_instance.cis-local]
  subaccount_id       = local.subaccount_id
  name                = "cis-local-binding"
  service_instance_id = btp_subaccount_service_instance.cis-local.id
}

# fetch token for hana admin API using client-credential service binding
data "http" "cis-api-token" {
  depends_on = [
    btp_subaccount_service_binding.cis-local-binding
  ]
  url    = "${local.cisCredentials.uaa.url}/oauth/token?grant_type=client_credentials"
  method = "POST"
  request_headers = {
    Authorization = "Basic ${local.cisBasicAuth}"
  }
}

# create kyma binding via provisioning API
data "http" "kymaruntime_bindings" {
  depends_on = [
    data.http.cis-api-token,
    local.instance_id
  ]

  provider = http-full

  url = "${local.cisCredentials.endpoints.provisioning_service_url}/provisioning/v1/environments/${local.instance_id}/bindings"
  method = "PUT"
  request_headers = {
    Authorization = "Bearer ${jsondecode(data.http.cis-api-token.response_body).access_token}"
    Accept        = "application/json"
    content-type  = "application/json"
  } 

  request_body = jsonencode({
    "parameters": {
      "expiration_seconds": 7200,
    } 
  })  
}
