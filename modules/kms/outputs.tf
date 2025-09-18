##########################
# Outputs for KMS Module
##########################

# Key Protect Instance ID
output "kms_instance_id" {
  description = "The ID of the Key Protect instance"
  value       = ibm_resource_instance.key_protect_instance.id
}

# Key Protect Instance GUID (used in IAM Authorization Policies)
output "kms_instance_guid" {
  description = "The GUID of the Key Protect instance"
  value       = ibm_resource_instance.key_protect_instance.guid
}

# Key Protect CRN (sometimes required for bindings or references)
output "kms_instance_crn" {
  description = "The CRN of the Key Protect instance"
  value       = ibm_resource_instance.key_protect_instance.crn
}

# Root key ID (if created)
output "kms_key_id" {
  description = "The ID of the root key created in Key Protect"
  value       = var.create_key ? ibm_kms_key.key[0].id : null
}

# Root key CRN (if created)
output "kms_key_crn" {
  description = "The CRN of the root key created in Key Protect"
  value       = var.create_key ? ibm_kms_key.key[0].crn : null
}
