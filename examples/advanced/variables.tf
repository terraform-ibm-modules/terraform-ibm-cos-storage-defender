########################################################################################################################
# Input variables
########################################################################################################################

#
# Module developer tips:
#   - Examples are references that consumers can use to see how the module can be consumed. They are not designed to be
#     flexible re-usable solutions for general consumption, so do not expose any more variables here and instead hard
#     code things in the example main.tf with code comments explaining the different configurations.
#   - For the same reason as above, do not add default values to the example inputs.
#

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example."
}

variable "prefix" {
  type        = string
  description = "A string value to prefix to all resources created by this example."
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable."
  default     = "Default"
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the new bucket. Required only if `create_cos_bucket` is true. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`."
  default     = "standard"
}

variable "object_locking_enabled" {
  description = "Whether to create an object lock configuration. Applies only if `object_versioning_enabled` and `create_cos_bucket` are true."
  type        = bool
  default     = false
}

variable "allowed_vpc" {
  description = "Single VPC JSON string with { name, region }, or empty string if not used"
  type        = string
  default     = ""
}

variable "allowed_vpc_crns" {
  description = "Comma-separated list of allowed VPC CRNs"
  type        = string
  default     = ""
}

variable "allowed_ip_addresses" {
  description = "Comma-separated list of allowed IP addresses"
  type        = string
  default     = ""
}

variable "allowed_network_zone_name" {
  description = "Optional custom name for CBR network zone"
  type        = string
  default     = ""
}
