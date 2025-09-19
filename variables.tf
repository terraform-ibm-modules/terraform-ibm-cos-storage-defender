##############################################################################
# Common variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud platform API key to deploy resources."
  sensitive   = true
}

variable "region" {
  description = "The region to provision the bucket. If specified, set `cross_region_location` and `single_site_location` to `null`."
  type        = string
  default     = "us-east"
}

variable "prefix" {
  type        = string
  nullable    = true
  default     = ""
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-us-south. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."
  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources."
  default     = "Default"
}


##############################################################################
# COS instance variables
##############################################################################

variable "cos_instance_name" {
  description = "The name for the IBM Cloud Object Storage instance provisioned by this module. Applies only if `create_cos_instance` is true."
  type        = string
  default     = "cos-cybervault"
}

variable "role" {
  description = "HMAC key role"
  type        = string
  default     = "Writer"
}

# variable "plan" {
#   description = "The plan to use when Object Storage instances are created. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-provision)."
#   type        = string
#   default     = "standard"
#   validation {
#     condition     = contains(["standard", "cos-one-rate-plan"], var.plan)
#     error_message = "The specified plan is not a valid selection!"
#   }
# }


##############################################################################
# KMS instance variables
##############################################################################

variable "key_protect_name" {
  type        = string
  description = "The name of the Key Protect instance to create."
  default     = "key-protect"
}

variable "kp_plan" {
  type        = string
  description = "Plan for the Key Protect instance. Valid plans are 'tiered-pricing' and 'cross-region-resiliency', for more information on these plans see [Key Protect pricing plan](https://cloud.ibm.com/docs/key-protect?topic=key-protect-pricing-plan)."
  default     = "tiered-pricing"

  validation {
    condition     = contains(["tiered-pricing", "cross-region-resiliency"], var.kp_plan)
    error_message = "`plan` must be one of: 'tiered-pricing', 'cross-region-resiliency'."
  }

  validation {
    condition     = var.kp_plan == "tiered-pricing" ? true : (var.kp_plan == "cross-region-resiliency" && contains(["us-south", "eu-de", "jp-tok"], var.region))
    error_message = "'cross-region-resiliency' is only available for the following regions: 'us-south', 'eu-de', 'jp-tok'."
  }
}

##############################################################################
# COS bucket variables
##############################################################################

variable "bucket_name" {
  type        = string
  description = "The name for the new Object Storage bucket."
  default     = "cybervault-bucket"
}

variable "bucket_storage_class" {
  type        = string
  description = "The storage class of the new bucket. Required only if `create_cos_bucket` is true. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`."
  default     = "standard"

  validation {
    condition     = can(regex("^standard$|^vault$|^cold$|^smart$|^onerate_active", var.bucket_storage_class))
    error_message = "Variable 'bucket_storage_class' must be 'standard', 'vault', 'cold', 'smart' or 'onerate_active'."
  }
}

variable "object_locking_enabled" {
  description = "Whether to create an object lock configuration. Applies only if `object_versioning_enabled` and `create_cos_bucket` are true."
  type        = bool
  default     = false
}

##############################################################################
# cloud logs variable
##############################################################################

variable "cloud_log_instance_name" {
  type        = string
  description = "The name for the Cloud Logs Instance."
  default     = "Cloud-Logs"
}

variable "cloud_logs_bucket_endpoint" {
  description = "The type of endpoint for the IBM terraform provider to manage the bucket. Possible values: `public`, `private`, `direct`."
  type        = string
  default     = "public"
  validation {
    condition     = contains(["public", "private", "direct"], var.cloud_logs_bucket_endpoint)
    error_message = "The specified cloud_logs_bucket_endpoint is not a valid selection!"
  }
}

variable "cloud_logs_endpoint" {
  description = "Service endpoint type for the Cloud Logs instance. Possible values: 'public', 'private', 'direct'."
  type        = string
  default     = "public-and-private"
}

variable "logs_bucket_name" {
  type        = string
  description = "The name for the new Object Storage bucket."
  default     = "icl-logs-bucket"
}

variable "metrics_bucket_name" {
  type        = string
  description = "The name for the new Object Storage bucket."
  default     = "icl-metrics-bucket"
}

variable "retention_period" {
  description = "Retention period (in days) for logs and metrics stored in Cloud Logs."
  type        = number
  default     = 7
}

##############################################################################
# CBR rule creation variables
##############################################################################

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
  default     = "cyber-zone"
}

variable "cos_allowed_endpoint_types" {
  description = "Allowed endpoint types for COS (public, private, all, or empty)"
  type        = string
  default     = "all"
}
