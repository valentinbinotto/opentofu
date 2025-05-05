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

variable "sg-0001-name" {
  type = string
  default = "sg-0001-forgejo-0001"
}
variable "keypair-0001-name" {
  type = string
  default = "key-0001"
}
variable "keypair-0001-pubkey" {
  type = string
  default = "ssh-rsa XYZ"
}
variable "vol-0001-name" {
  type = string
  default = "vol-0001"
}
variable "vol-0001-size" {
  type = number
  default = 30
}
variable "vol-0001-image" {
  type = string
  default = "debian 12 bookworm"
}
variable "instance-0001-name" {
  type = string
  default = "forgejo-0001"
}
variable "instance-0001-flavor" {
  type = string
  default = "t1-small"
}
variable "instance-0001-admpasswd" {
  type = string
  sensitive = true
}



variable "instance-0001-cloudinit-fqdn" {
  type = string
  default = "bastion-0001-net-0001.os-cloud-0001"
}
variable "instance-0001-cloudinit-dnsdomain" {
  type = string
  default = "network-0001.os-cloud-0001.vty-valentin-vty.net"
}
variable "instance-0001-cloudinit-username" {
  type = string
  default = "valentin"
}
variable "instance-0001-cloudinit-userfullname" {
  type = string
  default = "Valentin Binotto"
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


data "openstack_networking_network_v2" "network-0001" {
  name = var.network-0001-name
}

resource "openstack_networking_secgroup_v2" "sg-0001" {
  name = var.sg-0001-name
  description = "Allow no inbound traffic, allow all outbound traffic, Dual-Stack"
  stateful = true
}

resource "openstack_compute_keypair_v2" "keypair-0001" {
  name = var.keypair-0001-name
  public_key = var.keypair-0001-pubkey
}

data "openstack_images_image_v2" "vol-0001-image-0001" {
  name = var.vol-0001-image
}

data "openstack_compute_flavor_v2" "instance-0001-flavor-0001" {
  name = var.instance-0001-flavor
}

resource "openstack_blockstorage_volume_v3" "vol-0001" {
  name = var.vol-0001-name
  size = var.vol-0001-size
  image_id = data.openstack_images_image_v2.vol-0001-image-0001.id
}

resource "openstack_networking_port_v2" "network-0001-port-0001" {
  name = "${var.network-0001-name}-port-0001"
  admin_state_up = true
  network_id = data.openstack_networking_network_v2.network-0001.id
  security_group_ids = [openstack_networking_secgroup_v2.sg-0001.id]
}

resource "openstack_compute_instance_v2" "instance-0001" {
  name = var.instance-0001-name
  flavor_id = data.openstack_compute_flavor_v2.instance-0001-flavor-0001.id
  key_pair = openstack_compute_keypair_v2.keypair-0001.name
  admin_pass = var.instance-0001-admpasswd
  network {
    port = openstack_networking_port_v2.network-0001-port-0001.id
  }
  block_device {
    uuid = openstack_blockstorage_volume_v3.vol-0001.id
    source_type = "volume"
    boot_index = 0
    destination_type = "volume"
    delete_on_termination = false
  }
  user_data = <<-EOF2EOF
    #cloud-config
    fqdn: ${var.instance-0001-cloudinit-fqdn}
    create_hostname_file: true
    prefer_fqdn_over_hostname: true
    repo_update: true
    repo_upgrade: all
    manage_resolv_conf: true
    resolv_conf:
      domain: ${var.instance-0001-cloudinit-dnsdomain}
      nameservers: [1.1.1.1, 1.0.0.1]
    ssh_pwauth: false
    ssh_deletekeys: true
    disable_root: true
    ssh_authorized_keys: [${var.keypair-0001-pubkey}]
    timezone: US/Eastern
    users:
      - name: ${var.instance-0001-cloudinit-username}
        gecos: ${var.instance-0001-cloudinit-userfullname}
        primary_group: ${var.instance-0001-cloudinit-username}
        shell: /bin/bash
        sudo: ["ALL=(ALL) NOPASSWD:ALL"]
        lock_passwd: true
        ssh_authorized_keys:
          - ${var.keypair-0001-pubkey}
    packages:
    - git
    - curl
    - wget
    - openstack-clients
    - vim
    - awscli
    - tmux

    write_files:
      - path: /etc/systemd/system/ipfs.service
        content: |
          [Unit]
          Description=InterPlanetary File System (IPFS) daemon

          [Service]
          ExecStart=/usr/local/bin/ipfs daemon
          User=${var.instance-0001-cloudinit-username}
          Group=${var.instance-0001-cloudinit-username}
          
          RuntimeMaxSec=1800
          Restart=on-failure
          
          [Install]
          WantedBy=default.target
        permissions: '0644'
        owner: 'root:root'

      - path: /run/scripts/setup-ipfs.sh
        content: |
          #!/bin/bash
          wget https://dist.ipfs.tech/kubo/v0.34.1/kubo_v0.34.1_linux-amd64.tar.gz
          tar -xvzf kubo_v0.34.1_linux-amd64.tar.gz
          bash kubo/install.sh
          su -c "ipfs init" -s /bin/bash ${var.instance-0001-cloudinit-username}
          systemctl daemon-reload
          systemctl enable ipfs.service
          systemctl start ipfs.service
          ipfs pin add ${var.instance-0001-cloudinit-ipfscid}
        permissions: '0774'

    runcmd:
      - [ sh, "/run/scripts/setup-ipfs.sh" ]
        
  EOF2EOF
}

