# Equinix Network Edge: Fortinet FortiGate SD-WAN edge device

A Terraform module to create Fortinet FortiGate SD-WAN edge device
on the Equinix platform.

![Terraform status](https://github.com/equinix/terraform-equinix-fortigate-sdwan/workflows/Terraform/badge.svg)
![License](https://img.shields.io/github/license/equinix/terraform-equinix-fortigate-sdwan)

Supported device modes:

| Management Mode | License mode | Notes |
|-----------------|--------------|-------|
| Self managed    | Subscription |-|
| Self managed    | Bring your own license | `license_file` required |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| equinix/equinix | >= 1.1.0 |

## Providers

| Name | Version |
|---------|----------|
| equinix/equinix | >= 1.1.0 |

## Assumptions

* if `account_number` is not provided, then `Active` account within given metro
will be used
* most recent, stable version of a device software for a given `software_package`
will be used
* secondary device name will be same as primary with `-secondary` suffix added
* secondary device notification list will be same as for primary

## Example usage

```hcl
provider equinix {
  client_id     = var.equinix_client_id
  client_secret = var.equinix_client_secret
}

module "fortigate" {
  source           = "equinix/fortigate-sdwan/equinix"
  metro_code       = "SV"
  platform         = "medium"
  software_package = "VM04"
  name             = "tf-tst-fortigate-sdwan"
  hostname         = "pri"
  term_length      = 1
  notifications    = ["test@test.com"]
  secondary = {
    enabled    = true
    metro_code = "DC"
    hostname   = "sec"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|metro_code|Two-letter device location's metro code|`string`|`""`|yes|
|account_number|Billing account number for a device. If not provided, active account for a device metro code will be used|`string`|`0`|no|
|platform|Device hardware platform flavor: `small`, `medium`, `large`|`string`|`""`|yes|
|software_package|Device software package: `VM02`, `VM04`, `VM08`|`string`|`""`|yes|
|byol|Determines device licensing mode: bring your own license or subscription|`bool`|`false`|no|
|license_file|Path to the device license configuration file|`string`|`""`|no|
|name|Device name|`string`|`""`|yes|
|hostname|Device hostname prefix|`string`|`""`|yes|
|term_length|Term length in months: `1`, `12`, `24`, `36`|`number`|`0`|yes|
|notifications|List of email addresses that will receive notifications about device|`list(string)`|n/a|yes|
|acl_template_id|Identifier of a network ACL template that will be applied on a device|`string`|`""`|no|
|additional_bandwidth|Amount of additional internet bandwidth for a device, in Mbps|`number`|`0`|no|
|interface_count|Device interface count: either `10` or `18`|`number`|`10`|no|
|admin_password|Admin password|`string`|`""`|yes
|controller_ip_address|SD-WAN controller IP address|`string`|`""`|yes
|secondary|Map of secondary device attributes in redundant setup|`map`|N/A|no|

Secondary device map attributes:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|enabled|Value that determines if secondary device shall be created|`bool`|`false`|no|
|license_file|Path to the device license configuration file|`string`|`""`|no|
|metro_code|Two-letter secondary device location's metro code|`string`|`""`|yes|
|account_number|Billing account number for a device. If not provided, active account for a device metro code will be used|`string`|`0`|no|
|hostname|Device hostname prefix|`string`|`""`|yes|
|acl_template_id|Identifier of a network ACL template that will be applied on a secondary device|`string`|`""`|no|
|additional_bandwidth|Amount of additional internet bandwidth for a secondary device, in Mbps|`number`|`0`|no|
|admin_password|Admin password|`string`|`""`|yes
|controller_ip_address|SD-WAN controller IP address|`string`|`""`|yes

## Outputs

| Name | Description |
|------|-------------|
|id|Device identifier|
|status|Device provisioning status|
|license_status|Device license status|
|account_number|Device billing account number|
|cpu_count|Number of device CPU cores|
|memory|Amount of device memory|
|software_version|Device software version|
|region|Device region|
|ibx|Device IBX center code|
|ssh_ip_address|Device SSH interface IP address|
|ssh_ip_fqdn|Device SSH interface FQDN|
|interfaces|List of network interfaces present on a device|
|secondary|Secondary device outputs (same as for primary). Present when secondary device was enabled|
