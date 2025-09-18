##########################
# Module: Key Protect
##########################

resource "ibm_resource_instance" "key_protect_instance" {
  name              = var.key_protect_name
  resource_group_id = var.resource_group_id
  service           = "kms"
  plan              = var.plan
  location          = var.region
  tags              = var.tags
  parameters = {
    allowed_network : var.allowed_network
  }
}

resource "ibm_kms_key" "key" {
  count         = var.create_key ? 1 : 0
  instance_id   = ibm_resource_instance.key_protect_instance.guid
  key_name      = var.key_name
  key_ring_id   = var.kms_key_ring_id
  standard_key  = var.standard_key
  endpoint_type = var.endpoint_type
  force_delete  = var.force_delete
}
