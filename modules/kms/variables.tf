variable "key_protect_name" {
  type        = string
  description = "The name of the Key Protect instance to create."
  default     = "key-protect"
}

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group in which to create the Key Protect instance."
}

variable "plan" {
  type        = string
  description = "Plan for the Key Protect instance. Valid plans are 'tiered-pricing' and 'cross-region-resiliency'."
  default     = "tiered-pricing"

  validation {
    condition     = contains(["tiered-pricing", "cross-region-resiliency"], var.plan)
    error_message = "`plan` must be one of: 'tiered-pricing', 'cross-region-resiliency'."
  }

  validation {
    condition     = var.plan == "tiered-pricing" ? true : (var.plan == "cross-region-resiliency" && contains(["us-south", "eu-de", "jp-tok"], var.region))
    error_message = "'cross-region-resiliency' is only available for the following regions: 'us-south', 'eu-de', 'jp-tok'."
  }
}

variable "region" {
  type        = string
  description = "The IBM Cloud region where the Key Protect instance will be provisioned."
}

variable "tags" {
  type        = list(string)
  description = "Tags to apply to the Key Protect instance."
  default     = []
}

variable "allowed_network" {
  type        = string
  description = "Allowed networks for the Key Protect instance. Possible values: 'private-only', 'public-and-private'."
  default     = "public-and-private"

  validation {
    condition     = can(regex("public-and-private|private-only", var.allowed_network))
    error_message = "Valid values for allowed_network are 'public-and-private' or 'private-only'."
  }
}

variable "create_key" {
  type        = bool
  description = "Wheather to create key or not"
  default     = true
}

variable "key_name" {
  type        = string
  description = "The name of the KMS key to create."
  default     = "bucket-key"
}

variable "kms_key_ring_id" {
  type        = string
  description = "The ID of the Key Protect key ring where the KMS key will be created."
  default     = "default"
}

variable "standard_key" {
  type        = bool
  description = "Whether to create a standard key (true) or an imported key (false)."
  default     = false
}

variable "endpoint_type" {
  type        = string
  description = "The type of endpoint for the KMS key. Options: 'public', 'private'."
  default     = "public"
}

variable "force_delete" {
  type        = bool
  description = "Whether to force delete the key when deleting the resource."
  default     = true
}
