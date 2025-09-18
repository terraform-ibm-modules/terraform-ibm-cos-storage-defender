##########################
# Encrypted Bucket
##########################

resource "ibm_cos_bucket" "cos_bucket" {
  count                 = var.create_cos_bucket ? 1 : 0
  bucket_name           = var.bucket_name
  resource_instance_id  = var.cos_instance_id
  region_location       = var.region
  cross_region_location = var.cross_region_location
  single_site_location  = var.single_site_location
  endpoint_type         = var.management_endpoint_type_for_bucket
  storage_class         = var.bucket_storage_class
  hard_quota            = var.hard_quota
  force_delete          = var.force_delete
  object_lock           = var.object_locking_enabled ? true : null
  object_versioning {
    enable = var.object_locking_enabled
  }

  # Only set KMS key when encryption is enabled
  kms_key_crn = var.kms_encryption_enabled ? var.kms_key_crn : null
}
