variable "use_existing_cbr_zone" {
  description = "Whether to use an existing CBR zone"
  type        = bool
  default     = false
}

variable "existing_zone_id" {
  description = "Existing CBR Zone ID to update addresses"
  type        = string
  default     = null
}

variable "account_id" {
  description = "Account ID where the zone will be created"
  type        = string
}

variable "name" {
  description = "CBR zone name"
  type        = string
}

variable "zone_description" {
  description = "Description of the zone"
  type        = string
  default     = "CBR zone created by Terraform"
}

variable "addresses" {
  description = "List of address objects (VPC, IP, service, etc.)"
  type = list(object({
    type  = string
    value = string
    ref = optional(object({
      account_id       = string
      location         = string
      service_instance = string
      service_name     = string
      service_type     = string
    }))
  }))
  default = []
}

variable "excluded_addresses" {
  description = "List of excluded address objects"
  type = list(object({
    type  = string
    value = string
  }))
  default = []
}
