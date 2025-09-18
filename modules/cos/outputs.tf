##########################
# Outputs for COS Module
##########################

# COS instance ID (used for IAM policies and encryption)
output "cos_instance_id" {
  description = "The ID of the COS instance"
  value       = ibm_resource_instance.cos_instance.id
}

# COS instance GUID (sometimes required for IAM policies)
output "cos_instance_guid" {
  description = "The GUID of the COS instance"
  value       = ibm_resource_instance.cos_instance.guid
}

# HMAC Key ID
output "hmac_key_id" {
  description = "The ID of the HMAC key"
  value       = ibm_resource_key.hmac_key.id
}

# HMAC Credentials (access_key_id / secret_access_key)
output "hmac_credentials" {
  description = "The HMAC credentials (use with caution)"
  value       = ibm_resource_key.hmac_key.credentials
  sensitive   = true
}
