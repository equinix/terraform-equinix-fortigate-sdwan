provider "equinix" {
  client_id     = var.equinix_client_id
  client_secret = var.equinix_client_secret
}

module "fortigate" {
  source                = "equinix/fortigate-sdwan/equinix"
  version               = "1.0.0"
  byol                  = true
  license_file          = "/tmp/FGVM-pri.lic"
  name                  = "tf-fortigate-sdwan"
  metro_code            = var.metro_code_primary
  platform              = "medium"
  software_package      = "VM04"
  term_length           = 1
  notifications         = ["test@test.com"]
  hostname              = "forti-pri"
  additional_bandwidth  = 100
  interface_count       = 18
  acl_template_id       = equinix_network_acl_template.fortigate-pri.id
  admin_password        = "passwd"
  controller_ip_address = "1.1.1.1"
  secondary = {
    enabled               = true
    license_file          = "/tmp/FGVM-sec.lic"
    metro_code            = var.metro_code_secondary
    hostname              = "forti-sec"
    additional_bandwidth  = 100
    acl_template_id       = equinix_network_acl_template.fortigate-sec.id
    admin_password        = "passwd"
    controller_ip_address = "1.1.1.1"
  }
}

resource "equinix_network_acl_template" "fortigate-pri" {
  name        = "tf-fortigate-pri"
  description = "Primary Fortigate ACL template"
  metro_code  = var.metro_code_primary
  inbound_rule {
    subnets  = ["193.39.0.0/16", "12.16.103.0/24"]
    protocol = "TCP"
    src_port = "any"
    dst_port = "22"
  }
}

resource "equinix_network_acl_template" "fortigate-sec" {
  name        = "tf-fortigate-vm-sec"
  description = "Secondary Fortigate ACL template"
  metro_code  = var.metro_code_secondary
  inbound_rule {
    subnets  = ["193.39.0.0/16", "12.16.103.0/24"]
    protocol = "TCP"
    src_port = "any"
    dst_port = "22"
  }
}
