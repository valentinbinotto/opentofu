OpenStack & AWS (FRR instance, int. network and subnets, VPC, ext. connect, Multi-Cloud VPN)


terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
      version = "3.0.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "5.97.0"
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

variable "os-network-0001-name" {
  type = string
  default = "network-0001.os-cloud-0001.vty-valentin-vty.net"
}

variable "os-sg-0001-name" {
  type = string
  default = "os-sg-0001-router-0001"
}
variable "os-keypair-0001-name" {
  type = string
  default = "key-0001"
}
variable "os-keypair-0001-pubkey" {
  type = string
  default = "ssh-rsa XYZ"
}
variable "os-vol-0001-name" {
  type = string
  default = "vol-0001"
}
variable "os-vol-0001-size" {
  type = number
  default = 30
}
variable "os-vol-0001-image" {
  type = string
  default = "debian 12 bookworm"
}
variable "os-instance-0001-name" {
  type = string
  default = "bastion-0001"
}
variable "os-instance-0001-flavor" {
  type = string
  default = "t1-small"
}
variable "os-instance-0001-admpasswd" {
  type = string
  sensitive = true
}
variable "os-flip-0001-poolname" {
  type = string
  default = "ext-flippool-0001"
}


variable "os-instance-0001-cloudinit-fqdn" {
  type = string
  default = "router-0001-net-0001.os-cloud-0001"
}
variable "os-instance-0001-cloudinit-dnsdomain" {
  type = string
  default = "network-0001.os-cloud-0001.vty-valentin-vty.net"
}
variable "os-instance-0001-cloudinit-username" {
  type = string
  default = "valentin"
}
variable "os-instance-0001-cloudinit-userfullname" {
  type = string
  default = "Valentin Binotto"
}

variable "os-network-0001-cidr" {
  type = string
  description = "IPv4 Cidr of OpenStack Network-0001"
}

variable "aws-vpc-0001-id" {
  type = string
  description = "ID of AWS VPC"
}

variable "aws_region" { type = string }


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

provider "aws" {
  region = var.aws_region
}



# Gather Network Details

data "openstack_networking_network_v2" "os-network-0001" {
  name = var.os-network-0001-name
}

data "aws_vpc" "aws-vpc-0001" {
  id = var.aws-vpc-0001-id
}


# Elastic ips

resource "openstack_networking_floatingip_v2" "os-flip-0001" {
  pool = var.os-flip-0001-poolname
}

resource "aws_eip" "aws-eip-0001" {
  domain   = "vpc"
}

# OpenStack Ressources

resource "openstack_networking_secgroup_v2" "os-sg-0001" {
  name = var.os-sg-0001-name
  description = "Allow inbound traffic on port 22/tcp and 51820/tcp/udp from anywhere, allow all ingress from os-network-0001 ipv4 cidr allow all outbound traffic, Partly Dual-Stack"
  stateful = true
}

resource "openstack_networking_secgroup_rule_v2" "os-sg-0001-rule-0001" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.os-sg-0001.id
  protocol = "tcp"
  port_range_min = "22"
  port_range_max = "22"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "os-sg-0001-rule-0002" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.os-sg-0001.id
  protocol = "tcp"
  port_range_min = "22"
  port_range_max = "22"
  remote_ip_prefix = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "os-sg-0001-rule-0003" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.os-sg-0001.id
  remote_ip_prefix = var.os-network-0001-cidr
}

resource "openstack_networking_secgroup_rule_v2" "os-sg-0001-rule-0004" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.os-sg-0001.id
  protocol = "tcp"
  port_range_min = "51820"
  port_range_max = "51820"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "os-sg-0001-rule-0005" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.os-sg-0001.id
  protocol = "udp"
  port_range_min = "51820"
  port_range_max = "51820"
  remote_ip_prefix = "0.0.0.0/0"
}


resource "openstack_compute_keypair_v2" "os-keypair-0001" {
  name = var.os-keypair-0001-name
  public_key = var.os-keypair-0001-pubkey
}

data "openstack_images_image_v2" "os-vol-0001-image-0001" {
  name = var.os-vol-0001-image
}

data "openstack_compute_flavor_v2" "os-instance-0001-flavor-0001" {
  name = var.os-instance-0001-flavor
}

resource "openstack_blockstorage_volume_v3" "os-vol-0001" {
  name = var.os-vol-0001-name
  size = var.os-vol-0001-size
  image_id = data.openstack_images_image_v2.os-vol-0001-image-0001.id
}

resource "openstack_networking_port_v2" "os-network-0001-port-0001" {
  name = "${var.os-network-0001-name}-port-router-0001"
  admin_state_up = true
  network_id = data.openstack_networking_network_v2.os-network-0001.id
  security_group_ids = [openstack_networking_secgroup_v2.os-sg-0001.id]
}

resource "openstack_compute_instance_v2" "os-instance-0001" {
  name = var.os-instance-0001-name
  flavor_id = data.openstack_compute_flavor_v2.os-instance-0001-flavor-0001.id
  key_pair = openstack_compute_keypair_v2.os-keypair-0001.name
  admin_pass = var.os-instance-0001-admpasswd
  network {
    port = openstack_networking_port_v2.os-network-0001-port-0001.id
  }
  block_device {
    uuid = openstack_blockstorage_volume_v3.os-vol-0001.id
    source_type = "volume"
    boot_index = 0
    destination_type = "volume"
    delete_on_termination = false
  }
  user_data = <<-EOF2EOF
    #cloud-config
    fqdn: ${var.os-instance-0001-cloudinit-fqdn}
    create_hostname_file: true
    prefer_fqdn_over_hostname: true
    
    repo_update: true
    repo_upgrade: all
    
    manage_resolv_conf: true
    resolv_conf:
      domain: ${var.os-instance-0001-cloudinit-dnsdomain}
      nameservers: [1.1.1.1, 1.0.0.1]
      
    ssh_pwauth: false
    ssh_deletekeys: true
    disable_root: true
    ssh_authorized_keys: [${var.os-keypair-0001-pubkey}]
    
    timezone: US/Eastern
    
    users:
      - name: ${var.os-instance-0001-cloudinit-username}
        gecos: ${var.os-instance-0001-cloudinit-userfullname}
        primary_group: ${var.os-instance-0001-cloudinit-username}
        shell: /bin/bash
        sudo: ["ALL=(ALL) NOPASSWD:ALL"]
        lock_passwd: true
        ssh_authorized_keys:
          - ${var.os-keypair-0001-pubkey}
                  
    packages:
    - git
    - curl
    - wget
    - openstack-clients
    - vim
    - awscli
    - tmux
    - wireguard
        
  EOF2EOF
}


resource "openstack_networking_floatingip_associate_v2" "os-flip-0001-assoc-0001" {
  floating_ip = openstack_networking_floatingip_v2.os-flip-0001.address
  port_id = openstack_networking_port_v2.os-network-0001-port-0001.id
}
