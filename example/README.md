# Equinix Network Edge example: Fortinet FortiGate SD-WAN edge device

This example shows how to create redundant Fortinet FortiGate SD-WAN edge device
device on Platform Equinix using Equinix Fortigate SD-WAN Terraform module and
Equinix Terraform provider.

In addition to pair of Fortigate SD-WAN devices, following resources are being created
in this example:

* two ACL templates, one for each of the device

The devices are created in Equinix managed mode with license subscription.
Remaining parameters include:

* medium hardware platform (4CPU cores, 8GB of memory)
* VM04 software package
* 100 Mbps of additional internet bandwidth on each device
