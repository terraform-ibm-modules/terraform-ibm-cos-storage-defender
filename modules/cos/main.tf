##########################
# Module: COS Instance
##########################

resource "ibm_resource_instance" "cos_instance" {
  name              = var.cos_instance_name
  resource_group_id = var.resource_group_id
  service           = "cloud-object-storage"
  plan              = var.cos_plan
  location          = var.cos_location
  tags              = var.cos_tags
}

##########################
# HMAC Key
##########################

resource "ibm_resource_key" "hmac_key" {
  name                 = var.hmac_key_name
  resource_instance_id = ibm_resource_instance.cos_instance.id
  parameters           = { "HMAC" = true }
  role                 = var.hmac_role
}
