locals {
  devices = try(var.secondary.enabled, false) ? ["pri", "sec"] : ["pri"]
  metro_codes = try(var.secondary.enabled, false) ? {
    "pri" = var.metro_code
    "sec" = var.secondary.metro_code
    } : {
    "pri" = var.metro_code
  }
  account_numbers = {
    "pri" = try(var.account_number, 0)
    "sec" = try(var.secondary.account_number, 0)
  }
  metro_accounts = {
    for device in local.devices :
    device => local.account_numbers[device] > 0 ? local.account_numbers[device] : data.equinix_network_account.this[local.metro_codes[device]].number
  }
}

data "equinix_network_account" "this" {
  for_each   = toset(values(local.metro_codes))
  metro_code = each.key
  status     = "Active"
}

data "equinix_network_device_type" "this" {
  category    = "SDWAN"
  vendor      = "Fortinet"
  metro_codes = values(local.metro_codes)
}

data "equinix_network_device_platform" "this" {
  device_type = data.equinix_network_device_type.this.code
  flavor      = var.platform
}

data "equinix_network_device_software" "this" {
  device_type = data.equinix_network_device_type.this.code
  packages    = [var.software_package]
  stable      = true
  most_recent = true
}

resource "equinix_network_device" "this" {
  lifecycle {
    ignore_changes = [version, core_count]
  }
  self_managed         = true
  byol                 = var.byol
  license_file         = var.license_file != "" ? var.license_file : null
  name                 = var.name
  hostname             = var.hostname
  type_code            = data.equinix_network_device_type.this.code
  package_code         = var.software_package
  version              = data.equinix_network_device_software.this.version
  core_count           = data.equinix_network_device_platform.this.core_count
  metro_code           = var.metro_code
  account_number       = local.metro_accounts["pri"]
  term_length          = var.term_length
  notifications        = var.notifications
  acl_template_id      = var.acl_template_id != "" ? var.acl_template_id : null
  additional_bandwidth = var.additional_bandwidth > 0 ? var.additional_bandwidth : null
  interface_count      = var.interface_count > 0 ? var.interface_count : null
  vendor_configuration = {
    adminPassword = var.admin_password
    controller1   = var.controller_ip_address
  }
  dynamic "secondary_device" {
    for_each = try(var.secondary.enabled, false) ? [1] : []
    content {
      license_file         = try(var.secondary.license_file, null)
      name                 = "${var.name}-secondary"
      hostname             = var.secondary.hostname
      metro_code           = var.secondary.metro_code
      account_number       = local.metro_accounts["sec"]
      notifications        = var.notifications
      acl_template_id      = try(var.secondary.acl_template_id, null)
      additional_bandwidth = try(var.secondary.additional_bandwidth, null)
      vendor_configuration = {
        adminPassword = var.secondary.admin_password
        controller1   = var.secondary.controller_ip_address
      }
    }
  }
}
