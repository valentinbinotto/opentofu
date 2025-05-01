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
  description = "network-0001 IPv4 CIDR"
}
variable "network-0001-cidr-ipv6" {
  type = string
  description = "network-0001 IPv6 CIDR"
}

variable "ext-network-0001-name" {
  type = string
  default = "ext-network-0001.os-cloud-0001.vty-valentin-vty.net"
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
  enable_dhcp = false
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

resource "openstack_networking_secgroup_v2" "sg-0001" {
  name = "sg-0001"
  description = "Allow all egress, Drop all ingress, Dual-Stack"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "sg-0002" {
  name = "sg-0002"
  description = "Allow all egress, Allow all ingress, Dual-Stack"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "sg-0003" {
  name = "sg-0003"
  description = "Allow all egress, Allow all ingress from network-0001, Dual-Stack"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "sg-0004" {
  name = "sg-0004"
  description = "Allow all egress, Allow ssh ingress, Dual-Stack"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "sg-0005" {
  name = "sg-0005"
  description = "Allow no egress, Allow no ingress, Dual-Stack"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "sg-0006" {
  name = "sg-0006"
  description = "Allow all egress, Allow ssh,http,https ingress, Dual-Stack"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_v2" "sg-0007" {
  name = "sg-0007"
  description = "Allow all egress, Allow https ingress, Dual-Stack"
  delete_default_rules = true
}



resource "openstack_networking_router_v2" "rt-0001" {
  name = "rt-0001"
  admin_state_up = true
  external_network_id = openstack_networking_network_v2.ext-network-0001.id
  enable_snat = true
}

resource "openstack_networking_router_interface_v2" "rt-0001-int-0001" {
  router_id = openstack_networking_router_v2.rt-0001.id
  subnet_id = openstack_networking_subnet_v2.network-0001-subnet-0003
}

resource "openstack_networking_router_interface_v2" "rt-0001-int-0002" {
  router_id = openstack_networking_router_v2.rt-0001.id
  subnet_id = openstack_networking_subnet_v2.network-0001-subnet-0004
}

resource "openstack_networking_secgroup_rule_v2" "sg-0001-rule-0001" {
  direction = "egress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0001.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0001-rule-0002" {
  direction = "egress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0001.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0002-rule-0001" {
  direction = "egress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0002.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0002-rule-0002" {
  direction = "egress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0002.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0002-rule-0003" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0002.id
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0002-rule-0004" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0002.id
  remote_ip_prefix = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0003-rule-0001" {
  direction = "egress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0003.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0003-rule-0002" {
  direction = "egress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0003.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0003-rule-0003" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0003.id
  remote_ip_prefix = var.network-0001-cidr-ipv4
}

resource "openstack_networking_secgroup_rule_v2" "sg-0003-rule-0004" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0003.id
  remote_ip_prefix = var.network-0001-cidr-ipv6
}

resource "openstack_networking_secgroup_rule_v2" "sg-0004-rule-0001" {
  direction = "egress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0004.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0004-rule-0002" {
  direction = "egress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0004.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0004-rule-0003" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0004.id
  protocol = "tcp"
  port_range_min = "22"
  port_range_max = "22"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0004-rule-0004" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0004.id
  protocol = "tcp"
  port_range_min = "22"
  port_range_max = "22"
  remote_ip_prefix = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0006-rule-0001" {
  direction = "egress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0006.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0006-rule-0002" {
  direction = "egress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0006.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0006-rule-0003" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0006.id
  protocol = "tcp"
  port_range_min = "22"
  port_range_max = "22"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0006-rule-0004" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0006.id
  protocol = "tcp"
  port_range_min = "22"
  port_range_max = "22"
  remote_ip_prefix = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0006-rule-0005" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0006.id
  protocol = "tcp"
  port_range_min = "80"
  port_range_max = "80"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0006-rule-0006" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0006.id
  protocol = "tcp"
  port_range_min = "80"
  port_range_max = "80"
  remote_ip_prefix = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0006-rule-0007" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0006.id
  protocol = "tcp"
  port_range_min = "443"
  port_range_max = "443"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0006-rule-0008" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0006.id
  protocol = "tcp"
  port_range_min = "443"
  port_range_max = "443"
  remote_ip_prefix = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0007-rule-0001" {
  direction = "egress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0007.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0007-rule-0002" {
  direction = "egress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0007.id
}

resource "openstack_networking_secgroup_rule_v2" "sg-0007-rule-0003" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0007.id
  protocol = "tcp"
  port_range_min = "443"
  port_range_max = "443"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0007-rule-0004" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0007.id
  protocol = "tcp"
  port_range_min = "443"
  port_range_max = "443"
  remote_ip_prefix = "::/0"
}

resource "openstack_networking_port_v2" "network-0001-subnet-0003-port-0001" {
  name = "port-0001.subnet-0003.${var.network-0001-name}"
  network_id = openstack_networking_network_v2.network-0001.id
  admin_state_up = true
  security_group_ids = [openstack_networking_secgroup_v2.sg-0001.id]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.network-0001-subnet-0003.id
  }
}

resource "openstack_networking_floatingip_v2" "ext-network-0001-flip-0001" {
  pool = data.openstack_networking_network_v2.ext-network-0001.name
  subnet_id = openstack_networking_subnet_v2.ext-network-0001-subnet-0001.id
  port_id = openstack_networking_port_v2.network-0001-subnet-0003-port-0001.id
}



- instance
- s3 buckets