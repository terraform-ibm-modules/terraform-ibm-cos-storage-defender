variable "rule_description" {
  description = "Description for the CBR rule"
  type        = string
}

variable "enforcement_mode" {
  description = "Enforcement mode for the rule (enabled/disabled)"
  type        = string
  default     = "enabled"
}

variable "rule_contexts" {
  description = "List of contexts for the rule"
  type = list(object({
    attributes = list(object({
      name  = string
      value = string
    }))
  }))
  default = []
}

variable "resources" {
  description = "List of resources for the rule"
  type = list(object({
    attributes = list(object({
      name     = string
      value    = string
      operator = optional(string)
    }))
    tags = optional(list(object({
      name  = string
      value = string
    })))
  }))
  default = []
}

variable "operations" {
  description = "List of operations for the rule"
  type = list(object({
    api_types = list(object({
      api_type_id = string
    }))
  }))
  default = []
}
