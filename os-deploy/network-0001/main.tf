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

variable "network-0001-subnet-0001-cidr" {
  type = string
  description = "network-0001-subnet-0001 IPv4 CIDR"
}
variable "network-0001-subnet-0002-cidr" {
  type = string
  description = "network-0001-subnet-0002 IPv6 CIDR"
}
variable "network-0001-subnet-0003-cidr" {
  type = string
  description = "network-0001-subnet-0003 IPv4 CIDR"
}
variable "network-0001-subnet-0004-cidr" {
  type = string
  description = "network-0001-subnet-0004 IPv6 CIDR"
}

variable "ext-network-0001-name" {
  type = string
  default = "ext-network-0001.os-cloud-0001.vty-valentin-vty.net"
}
variable "ext-network-0001-pronettype" {
  type = string
  description = "Type of provider network (flat/vlan/local)"
  default = "flat"
}
variable "ext-network-0001-prophynet" {
  type = string
  description = "Name of physical provider network (exp. br-provider)"
  default = "br-provider"
}
variable "ext-network-0001-subnet-0001-cidr" {
  type = string
  description = "ext-network-0001-subnet-0001 IPv4 CIDR"
}
variable "ext-network-0001-subnet-0002-cidr" {
  type = string
  description = "ext-network-0001-subnet-0002 IPv4 CIDR"
}
variable "ext-network-0001-subnet-0003-cidr" {
  type = string
  description = "ext-network-0001-subnet-0003 IPv6 CIDR"
}
variable "ext-network-0001-subnet-0004-cidr" {
  type = string
  description = "ext-network-0001-subnet-0004 IPv6 CIDR"
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
}

resource "openstack_networking_subnet_v2" "network-0001-subnet-0001" {
  name = "subnet-0001.${var.network-0001-name}"
  network_id = openstack_networking_network_v2.network-0001.id
  cidr = var.network-0001-subnet-0001-cidr
  ip_version = 4
  gateway_ip = cidrhost(var.network-0001-subnet-0001-cidr, 1)
  enable_dhcp = false
}

resource "openstack_networking_subnet_v2" "network-0001-subnet-0002" {
  name = "subnet-0002.${var.network-0001-name}"
  network_id = openstack_networking_network_v2.network-0001.id
  cidr = var.network-0001-subnet-0002-cidr
  ip_version = 6
  ipv6_address_mode = "slaac"
  ipv6_ra_mode = "slaac"
  gateway_ip = cidrhost(var.network-0001-subnet-0002-cidr, 1)
  enable_dhcp = false
}

resource "openstack_networking_subnet_v2" "network-0001-subnet-0003" {
  name = "subnet-0003.${var.network-0001-name}"
  network_id = openstack_networking_network_v2.network-0001.id
  cidr = var.network-0001-subnet-0003-cidr
  ip_version = 4
  gateway_ip = cidrhost(var.network-0001-subnet-0003-cidr, 1)
  enable_dhcp = true
}

resource "openstack_networking_subnet_v2" "network-0001-subnet-0004" {
  name = "subnet-0004.${var.network-0001-name}"
  network_id = openstack_networking_network_v2.network-0001.id
  cidr = var.network-0001-subnet-0004-cidr
  ip_version = 6
  ipv6_address_mode = "slaac"
  ipv6_ra_mode = "slaac"
  gateway_ip = cidrhost(var.network-0001-subnet-0004-cidr, 1)
  enable_dhcp = true
}

resource "openstack_networking_secgroup_v2" "sg-0001" {
  name "sg-0001"
}

resource "openstack_networking_secgroup_v2" "sg-0002" {
  name "sg-0002"
}

resource "openstack_networking_secgroup_v2" "sg-0003" {
  name "sg-0003"
}

resource "openstack_networking_secgroup_v2" "sg-0004" {
  name "sg-0004"
}

resource "openstack_networking_network_v2" "ext-network-0001" {
  name = var.ext-network-0001-name
  admin_state_up = true
  external = true
  shared = true
  provider_network_type = var.ext-network-0001-pronettype
  provider_physical_network = var.ext-network-0001-prophynet
}
  
resource "openstack_networking_subnet_v2" "ext-network-0001-subnet-0001" {
  name = "subnet-0001.${var.ext-network-0001-name}"
  network_id = openstack_networking_network_v2.ext-network-0001.id
  cidr = var.ext-network-0001-subnet-0001-cidr
  ip_version = 4
  gateway_ip = cidrhost(var.ext-network-0001-subnet-0001-cidr, 1)
  enable_dhcp = false
}

resource "openstack_networking_subnet_v2" "ext-network-0001-subnet-0002" {
  name = "subnet-0002.${var.ext-network-0001-name}"
  network_id = openstack_networking_network_v2.ext-network-0001.id
  cidr = var.ext-network-0001-subnet-0002-cidr
  ip_version = 4
  gateway_ip = cidrhost(var.ext-network-0001-subnet-0002-cidr, 1)
  enable_dhcp = false
}

resource "openstack_networking_subnet_v2" "ext-network-0001-subnet-0003" {
  name = "subnet-0003.${var.ext-network-0001-name}"
  network_id = openstack_networking_network_v2.ext-network-0001.id
  cidr = var.ext-network-0001-subnet-0003-cidr
  ip_version = 6
  ipv6_address_mode = "slaac"
  ipv6_ra_mode = "slaac"
  gateway_ip = cidrhost(var.ext-network-0001-subnet-0003-cidr, 1)
  enable_dhcp = false
}

resource "openstack_networking_subnet_v2" "ext-network-0001-subnet-0004" {
  name = "subnet-0004.${var.ext-network-0001-name}"
  network_id = openstack_networking_network_v2.ext-network-0001.id
  cidr = var.ext-network-0001-subnet-0004-cidr
  ip_version = 6
  ipv6_address_mode = "slaac"
  ipv6_ra_mode = "slaac"
  gateway_ip = cidrhost(var.ext-network-0001-subnet-0004-cidr, 1)
  enable_dhcp = false
}

resource "openstack_networking_router_v2" "rt-0001" {
  name = "rt-0001"
}

resource "openstack_networking_router_v2" "rt-0002" {
  name = "rt-0002"
}

router
secgroup rules
floating ip
port secgroup assoc
router interface
router route
subnet route