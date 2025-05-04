terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "3.0.0"
    }
  }
}

variable "os_user_name" { type = string }
variable "os_tenant_name" { type = string }
variable "os_user_password" {
  type = string
  sensitive = true
}
variable "os_auth_url" { type = string }
variable "os_region" { type = string }
variable "os_user_domain_name" { type = string }
variable "os_project_domain_name" { type = string }
variable "os_domain_name" { type = string }

variable "network-0001-name" {
  type = string
  default = "network-0001.os-cloud-0001.vty-valentin-vty.net"
}

variable "network-0001-cidr-ipv4" {
  type = string
  description = "network-0001 IPv4 CIDR (/16)"
}
variable "network-0001-cidr-ipv6" {
  type = string
  description = "network-0001 IPv6 CIDR (/48)"
}

variable "ext-network-0001-name" {
  type = string
  description = "Name of external network"
}

provider "openstack" {
  user_name = var.os_user_name
  tenant_name = var.os_tenant_name
  password = var.os_user_password
  auth_url = var.os_auth_url
  region = var.os_region
  user_domain_name = var.os_user_domain_name
  project_domain_name = var.os_project_domain_name
  domain_name = var.os_domain_name
  enable_logging = true
}


#variable "cloud" {
#  type = string
#  default = "os-cloud-0001"
#  sensitive = false
#}

#provider "openstack" {
#  cloud = var.cloud
#}


resource "openstack_networking_network_v2" "network-0001" {
  name = var.network-0001-name
  admin_state_up = "true"
  shared = "false"
}

resource "openstack_networking_subnet_v2" "network-0001-subnet-0001" {
  name = "subnet-0001.${var.network-0001-name}"
  network_id = openstack_networking_network_v2.network-0001.id
  cidr = cidrsubnet(var.network-0001-cidr-ipv4, 8, 1)
  ip_version = 4
  gateway_ip = cidrhost(cidrsubnet(var.network-0001-cidr-ipv4, 8, 1), 1)
  enable_dhcp = false
}

resource "openstack_networking_subnet_v2" "network-0001-subnet-0002" {
  name = "subnet-0002.${var.network-0001-name}"
  network_id = openstack_networking_network_v2.network-0001.id
  cidr = cidrsubnet(var.network-0001-cidr-ipv6, 16, 1)
  ip_version = 6
  ipv6_address_mode = "slaac"
  ipv6_ra_mode = "slaac"
  gateway_ip = cidrhost(cidrsubnet(var.network-0001-cidr-ipv6, 16, 1), 1)
  enable_dhcp = true
}

resource "openstack_networking_subnet_v2" "network-0001-subnet-0003" {
  name = "subnet-0003.${var.network-0001-name}"
  network_id = openstack_networking_network_v2.network-0001.id
  cidr = cidrsubnet(var.network-0001-cidr-ipv4, 8, 2)
  ip_version = 4
  gateway_ip = cidrhost(cidrsubnet(var.network-0001-cidr-ipv4, 8, 2), 1)
  enable_dhcp = true
}

resource "openstack_networking_subnet_v2" "network-0001-subnet-0004" {
  name = "subnet-0004.${var.network-0001-name}"
  network_id = openstack_networking_network_v2.network-0001.id
  cidr = cidrsubnet(var.network-0001-cidr-ipv6, 16, 2)
  ip_version = 6
  ipv6_address_mode = "slaac"
  ipv6_ra_mode = "slaac"
  gateway_ip = cidrhost(cidrsubnet(var.network-0001-cidr-ipv6, 16, 2), 1)
  enable_dhcp = true
}

data "openstack_networking_network_v2" "ext-network-0001" {
  name = var.ext-network-0001-name
}

resource "openstack_networking_router_v2" "ext-net-rt-0001" {
  name = "ext-net-rt-0001"
  admin_state_up = true
  external_network_id = data.openstack_networking_network_v2.ext-network-0001.id
  # enable_snat = true
}

resource "openstack_networking_router_interface_v2" "ext-net-rt-0001-int-0001" {
  router_id = openstack_networking_router_v2.ext-net-rt-0001.id
  subnet_id = openstack_networking_subnet_v2.network-0001-subnet-0003.id
}

resource "openstack_networking_router_interface_v2" "ext-net-rt-0001-int-0002" {
  router_id = openstack_networking_router_v2.ext-net-rt-0001.id
  subnet_id = openstack_networking_subnet_v2.network-0001-subnet-0004.id
}