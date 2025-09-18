# Looks up an existing resource group by name

data "ibm_resource_group" "existing_resource_group" {
  name = var.existing_resource_group_name
}

# Configure locals
locals {
  effective_cos_instance_name = (
    var.cos_instance_name != "" ? var.cos_instance_name : "cos-cybervault"
  )

  safe_prefix       = var.prefix != null && var.prefix != "" ? "${var.prefix}-" : ""
  cos_instance_name = "${local.safe_prefix}${local.effective_cos_instance_name}"
  cos_plan          = var.bucket_storage_class == "onerate_active" ? "cos-one-rate-plan" : "standard"
  hmac_key_name     = "${local.safe_prefix}hmac-creds"
}

# Create Cos Instance
module "cos" {
  source            = "./modules/cos"
  ibmcloud_api_key  = var.ibmcloud_api_key
  cos_instance_name = local.cos_instance_name
  cos_plan          = local.cos_plan
  resource_group_id = data.ibm_resource_group.existing_resource_group.id
  hmac_key_name     = local.hmac_key_name
  hmac_role         = var.role
}

# Create CBR rule
data "ibm_iam_account_settings" "iam_account_settings" {
}


##############################################################################

# Creates Key Protect and Key
##############################################################################

# Configure locals for KMS
locals {
  effective_key_protect_name = (
    var.key_protect_name != "" ? var.key_protect_name : "key-protect"
  )
  key_protect_name = "${local.safe_prefix}${local.effective_key_protect_name}"
  create_key       = true
  key_name         = "${local.safe_prefix}${var.bucket_name}-cos-key"
}

module "kms" {
  source            = "./modules/kms"        # Path to your Key Protect module
  key_protect_name  = local.key_protect_name # Or var.key_protect_name
  resource_group_id = data.ibm_resource_group.existing_resource_group.id
  plan              = var.kp_plan # Optional, default "standard"
  region            = var.region
  create_key        = local.create_key
  key_name          = local.key_name
}

##############################################################################

# Create Authorization Policy between COS and KMS.
##############################################################################


# Local flag to toggle auth policy creation
locals {
  create_authorization_policy = true
}

# COS → KMS authorization policy
resource "ibm_iam_authorization_policy" "cos_to_kms" {
  count = local.create_authorization_policy ? 1 : 0

  source_service_name         = "cloud-object-storage"
  source_resource_instance_id = module.cos.cos_instance_guid
  target_service_name         = "kms"
  target_resource_instance_id = module.kms.kms_instance_guid
  roles                       = ["Reader"]
}

##############################################################################

# Create Cos Bucket
##############################################################################
resource "random_id" "bucket_suffix" {
  byte_length = 2
}

locals {
  effective_bucket_name = (
    var.bucket_name != "" ? var.bucket_name : "cybervault-bucket"
  )
  bucket_name = "${local.safe_prefix}${local.effective_bucket_name}-${random_id.bucket_suffix.hex}"

  # based on region set region location for resiliancy
  region                 = var.region
  cross_region_location  = null
  single_site_location   = null
  kms_encryption_enabled = true
}

module "cos_bucket" {
  source                 = "./modules/buckets"
  region                 = var.region
  bucket_storage_class   = var.bucket_storage_class
  cos_instance_id        = module.cos.cos_instance_id
  bucket_name            = local.bucket_name
  object_locking_enabled = var.object_locking_enabled
  cross_region_location  = local.cross_region_location
  single_site_location   = local.single_site_location
  kms_encryption_enabled = local.kms_encryption_enabled
  kms_key_crn            = local.kms_encryption_enabled ? module.kms.kms_key_crn : null
  depends_on             = [ibm_iam_authorization_policy.cos_to_kms]
}

##############################################################################

# Create Cloud logs and data/metrics bucket
##############################################################################

# ICL

locals {
  logs_bucket_name    = "${local.safe_prefix}${var.logs_bucket_name}-${random_id.bucket_suffix.hex}"
  metrics_bucket_name = "${local.safe_prefix}${var.metrics_bucket_name}-${random_id.bucket_suffix.hex}"
  bucket_configs = {
    logs    = local.logs_bucket_name
    metrics = local.metrics_bucket_name
  }
}
# Logs Buckets
module "cloud_logs_buckets" {
  for_each                            = local.bucket_configs
  source                              = "./modules/buckets"
  region                              = var.region
  bucket_storage_class                = var.bucket_storage_class
  cos_instance_id                     = module.cos.cos_instance_id
  bucket_name                         = each.value
  kms_encryption_enabled              = local.kms_encryption_enabled
  kms_key_crn                         = local.kms_encryption_enabled ? module.kms.kms_key_crn : null
  management_endpoint_type_for_bucket = var.cloud_logs_bucket_endpoint
  depends_on                          = [ibm_iam_authorization_policy.cos_to_kms]
}

# Cloud logs

locals {
  effective_cloud_log_instance_name = (
    var.cloud_log_instance_name != "" ? var.cloud_log_instance_name : "Cloud-Logs"
  )
  cloud_log_instance_name = "${local.safe_prefix}${local.effective_cloud_log_instance_name}"
  data_storage = {
    logs_data = {
      enabled         = true
      bucket_crn      = module.cloud_logs_buckets["logs"].cos_bucket_crn
      bucket_endpoint = module.cloud_logs_buckets["logs"].cos_bucket_direct_endpoint
    }

    metrics_data = {
      enabled         = true
      bucket_crn      = module.cloud_logs_buckets["metrics"].cos_bucket_crn
      bucket_endpoint = module.cloud_logs_buckets["metrics"].cos_bucket_direct_endpoint
    }
  }
}

resource "ibm_iam_authorization_policy" "cos_policy" {
  count               = 1
  source_service_name = "logs"
  roles               = ["Writer"]
  description         = "Allow Cloud logs instances `Writer` access to the COS bucket with ID "

  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = "cloud-object-storage"
  }

  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = data.ibm_iam_account_settings.iam_account_settings.account_id
  }

  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = module.cos.cos_instance_guid
  }
}

module "cloud_logs" {
  source            = "./modules/cloud_logs"
  data_storage      = local.data_storage
  resource_group_id = data.ibm_resource_group.existing_resource_group.id
  icl_instance_name = local.cloud_log_instance_name
  retention_period  = var.retention_period
  service_endpoints = var.cloud_logs_endpoint
  region            = var.region
  depends_on        = [ibm_iam_authorization_policy.cos_policy]
}

##############################################################################
# Context Based Restrictions (CBR)
##############################################################################

locals {
  account_id = data.ibm_iam_account_settings.iam_account_settings.account_id

  # Allowed endpoint types
  endpoint_context = (
    var.cos_allowed_endpoint_types == "all" ? [
      { name = "endpointType", value = "private" },
      { name = "endpointType", value = "public" }
    ] :
    var.cos_allowed_endpoint_types != "" ? [
      { name = "endpointType", value = var.cos_allowed_endpoint_types }
    ] : []
  )

  # Parse inputs for zone creation
  allowed_vpc_obj           = (var.allowed_vpc != "" && var.allowed_vpc != "-") ? jsondecode(var.allowed_vpc) : null
  allowed_vpc_crns_list     = var.allowed_vpc_crns != "" ? [for crn in split(",", var.allowed_vpc_crns) : trimspace(crn)] : []
  allowed_ip_addresses_list = var.allowed_ip_addresses != "" ? [for ip in split(",", var.allowed_ip_addresses) : trimspace(ip)] : []
}

# Fetch the VPC if provided
data "ibm_is_vpc" "single_vpc" {
  count = (
    local.allowed_vpc_obj != null &&
    try(local.allowed_vpc_obj.region, null) == var.region
  ) ? 1 : 0

  name = local.allowed_vpc_obj.name
}

locals {
  allowed_vpc_list = length(data.ibm_is_vpc.single_vpc) > 0 ? [data.ibm_is_vpc.single_vpc[0].crn] : []
  use_custom_zone  = length(local.allowed_vpc_list) > 0 || length(local.allowed_vpc_crns_list) > 0 || length(local.allowed_ip_addresses_list) > 0
}

##############################################################################
# CBR Zone
##############################################################################

module "cbr_zone" {
  source     = "./modules/cbr-zone-module"
  count      = local.use_custom_zone ? 1 : 0
  name       = "${local.safe_prefix}cbr-zone"
  account_id = local.account_id

  addresses = concat(
    [for vpc in local.allowed_vpc_list : { type = "vpc", value = vpc }],
    [for crn in local.allowed_vpc_crns_list : { type = "vpc", value = crn }],
    [for ip in local.allowed_ip_addresses_list : { type = "ipAddress", value = ip }]
  )

  excluded_addresses = []
}

##############################################################################
# Final context attributes for the rule
##############################################################################
locals {
  context_attributes = concat(
    local.endpoint_context,
    local.use_custom_zone ? [
      { name = "networkZoneId", value = module.cbr_zone[0].cbr_zone_id }
    ] : []
  )

  cos_rule_resources = [
    {
      attributes = [
        { name = "accountId", value = local.account_id },
        { name = "serviceName", value = "cloud-object-storage" },
        { name = "serviceInstance", value = module.cos.cos_instance_guid, operator = "stringEquals" }
      ]
    }
  ]

  cos_rule_operations = [
    {
      api_types = [
        { api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:" }
      ]
    }
  ]
}

##############################################################################
# CBR Rule
##############################################################################
module "cbr_rule" {
  source           = "./modules/cbr-rule-module"
  count            = length(local.context_attributes) > 0 ? 1 : 0
  rule_description = "CBR rule for COS"
  enforcement_mode = "enabled"

  # ✅ Each context gets its own attribute list
  rule_contexts = [
    for ctx in local.context_attributes : {
      attributes = [ctx]
    }
  ]

  resources  = local.cos_rule_resources
  operations = local.cos_rule_operations

  depends_on = [
    module.cos,
    module.cos_bucket,
    module.cloud_logs_buckets,
    module.cloud_logs,
    module.kms
  ]
}

