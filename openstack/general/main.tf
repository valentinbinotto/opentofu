variable "cloud" {
  type = string
  default = "openstack-flex"
  description = "The cloud configuration to use from clouds.yaml"
  sensitive = false
}

variable "ssh-public-key-path" {
  type = string
  default = "/home/$USER/.ssh/id_rsa.pub"
  description = "path to public key you would like to add to openstack"
  sensitive = false
}

variable "network-0001-name" {
  type = string
  default = "network-0001.os-cloud-0001.vty-valentin-vty.net"
}

#variable "os_project_id" { type = string }

terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "3.0.0"
    }
  }
}

provider "openstack" {
  cloud = var.cloud
}

#provider "openstack" {
#  auth_url = var.os_auth_url
#  project_id = var.os_project_id
#  application_credential_secret = var.os_application_credential_secret
#}

## Get external network
data openstack_networking_network_v2 "external-network" {
  name = "PUBLICNET"
}


resource openstack_networking_network_v2 "network-0001" {
  name = var.network-0001-name}

## Create router
resource openstack_networking_router_v2 "external-router" {
  provider = openstack
  name = "external-router"
  admin_state_up = true
  external_network_id = data.openstack_networking_network_v2.external-network.id
}

## Create internal network
resource openstack_networking_network_v2 "internal-network" {
  name = "internal-network"
  admin_state_up = true
  external = false
  port_security_enabled = true
}

## Create internal subnet
resource openstack_networking_subnet_v2 "internal-subnet" {
  name = "internal-subnet"
  network_id = openstack_networking_network_v2.internal-network.id
  cidr = "172.16.0.0/16"
  ip_version = 4
  enable_dhcp = true
  allocation_pool {
    start = "172.16.0.100"
    end = "172.16.0.200"
  }
}

## Create internal router interface
resource openstack_networking_router_interface_v2 "internal-router-interface" {
  router_id = openstack_networking_router_v2.external-router.id
  subnet_id = openstack_networking_subnet_v2.internal-subnet.id
}

## Create security group for public ssh
resource openstack_networking_secgroup_v2 "public-ssh" {
  name = "public-ssh"
}

## Create security group for public icmp
resource openstack_networking_secgroup_v2 "public-icmp" {
  name = "public-icmp"
}

## Create security group for public web
resource openstack_networking_secgroup_v2 "public-web" {
  name = "public-web"
}

## Create security group rule for public-ssh
resource openstack_networking_secgroup_rule_v2 "public-ssh" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.public-ssh.id
  protocol = "tcp"
  port_range_min = "22"
  port_range_max = "22"
  remote_ip_prefix = "0.0.0.0/0"
}

## Create security group rule for public icmp
resource openstack_networking_secgroup_rule_v2 "public-icmp" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.public-icmp.id
  protocol = "icmp"
  remote_ip_prefix = "0.0.0.0/0"
}

## Create security group rule for public http
resource openstack_networking_secgroup_rule_v2 "public-http" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.public-web.id
  protocol = "tcp"
  port_range_min = "80"
  port_range_max = "80"
  remote_ip_prefix = "0.0.0.0/0"
}

## Create security group rule for public https
resource openstack_networking_secgroup_rule_v2 "public-https" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.public-web.id
  protocol = "tcp"
  port_range_min = "443"
  port_range_max = "443"
  remote_ip_prefix = "0.0.0.0/0"
}

## Keypair
resource openstack_compute_keypair_v2 "public-key" {
  name = "public-key"
  public_key = file(var.ssh-public-key-path)
}

## Create network port for bastion server
resource openstack_networking_port_v2 "bastion" {
  name = "bastion"
  network_id = openstack_networking_network_v2.internal-network.id
  admin_state_up = true
  
  # Add security groups for public-ssh and public-icmp
  security_group_ids = [openstack_networking_secgroup_v2.public-ssh.id, openstack_networking_secgroup_v2.public-icmp.id]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.internal-subnet.id
  }
}

## Create bastion instance
resource openstack_compute_instance_v2 "bastion" {
  name = "bastion-server.internal"
  image_name = "Ubuntu-24.04"
  flavor_name = "t1.small"
  key_pair = openstack_compute_keypair_v2.public-key.name
  network {
    port = openstack_networking_port_v2.bastion.id
  }
  metadata = {
    role = "bastion"
  }
}

## Create floating ip for bastion server
resource openstack_networking_floatingip_v2 "bastion" {
  pool = "PUBLICNET"
  port_id = openstack_networking_port_v2.bastion.id
}

## outputs
output "bastion-floating-ip" {
  value = openstack_networking_floatingip_v2.bastion.address
}