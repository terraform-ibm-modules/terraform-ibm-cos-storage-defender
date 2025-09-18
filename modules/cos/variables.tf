variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud platform API key to deploy resources."
  sensitive   = true
}

variable "cos_instance_name" {
  description = "The name for the IBM Cloud Object Storage instance provisioned by this solution. If a value is passed for `prefix`, the instance will be named with the prefix value in the format of `<prefix>-value`."
  type        = string
  default     = "cos-cybervault"
}

variable "cos_location" {
  description = "The location for the Object Storage instance."
  type        = string
  default     = "global"
}

variable "resource_group_id" {
  type        = string
  description = "The resource group ID for the new Object Storage instance."
}

variable "cos_plan" {
  description = "The plan to use when Object Storage instances are created. Possible values: `standard`, `cos-one-rate-plan`.  For more details refer https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-provision."
  type        = string
  validation {
    condition     = contains(["standard", "cos-one-rate-plan"], var.cos_plan)
    error_message = "The specified cos_plan is not a valid selection!"
  }
}

variable "cos_tags" {
  description = "A list of tags to apply to the Object Storage instance."
  type        = list(string)
  default     = []
}

variable "hmac_key_name" {
  description = "HMAC key name for COS instance"
  type        = string
  default     = "cos-cybervault-hmac"
}

variable "hmac_role" {
  description = "HMAC key role"
  type        = string
  default     = "Writer"
}