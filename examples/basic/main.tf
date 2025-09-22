########################################################################################################################
# COS
########################################################################################################################

#
# Developer tips:
#   - Call the local module / modules in the example to show how they can be consumed
#   - Include the actual module source as a code comment like below so consumers know how to consume from correct location
#

module "cyber_vault" {
  source = "../.."

  # common variables
  existing_resource_group_name = var.resource_group
  ibmcloud_api_key             = var.ibmcloud_api_key
  prefix                       = var.prefix

  # cos instance related variables
  cos_instance_name = "cos-cybervault"

  # KMS instance related variables
  key_protect_name = "keyprotect"

  # bucket related variables.
  bucket_storage_class   = var.bucket_storage_class
  bucket_name            = "cybervault-bucket"
  object_locking_enabled = var.object_locking_enabled

  # Cloud logs variables
  cloud_log_instance_name = "icl-cyber"

  # CBR related variables
  allowed_vpc               = ""
  allowed_vpc_crns          = ""
  allowed_ip_addresses      = ""
  allowed_network_zone_name = ""
}
