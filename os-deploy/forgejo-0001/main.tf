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
variable "flip-0001-poolname" {
  type = string
  default = "ext-flippool-0001"
}

variable "instance-0001-cloudinit-forgejopath" {
  type = string
  default = "/opt/forgejo"
}
variable "instance-0001-cloudinit-forgejodomain" {
  type = string
  default = "git-prd-0001-ext.external-cloud-infrastructure.com"
}
variable "instance-0001-cloudinit-dbpasswd" {
  type = string
  sensitive = true
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
  description = "Allow inbound traffic on port 443, port 80 and port 22 from anywhere, allow all outbound traffic, Dual-Stack"
  stateful = true
}

resource "openstack_networking_secgroup_rule_v2" "sg-0001-rule-0001" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0001.id
  protocol = "tcp"
  port_range_min = "22"
  port_range_max = "22"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0001-rule-0002" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0001.id
  protocol = "tcp"
  port_range_min = "22"
  port_range_max = "22"
  remote_ip_prefix = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0001-rule-0003" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0001.id
  protocol = "tcp"
  port_range_min = "443"
  port_range_max = "443"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0001-rule-0004" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0001.id
  protocol = "tcp"
  port_range_min = "443"
  port_range_max = "443"
  remote_ip_prefix = "::/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0001-rule-0005" {
  direction = "ingress"
  ethertype = "IPv4"
  security_group_id = openstack_networking_secgroup_v2.sg-0001.id
  protocol = "tcp"
  port_range_min = "80"
  port_range_max = "80"
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "sg-0001-rule-0006" {
  direction = "ingress"
  ethertype = "IPv6"
  security_group_id = openstack_networking_secgroup_v2.sg-0001.id
  protocol = "tcp"
  port_range_min = "80"
  port_range_max = "80"
  remote_ip_prefix = "::/0"
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
  name = "${var.network-0001-name}-port-forgejo-0001"
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
    #!/bin/bash
    # Add Docker's official GPG key:
    apt-get update
    apt-get install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    
    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Define vars
    export PATHGITSETUP="${var.instance-0001-cloudinit-forgejopath}"
    export GITDOMAIN="${var.instance-0001-cloudinit-forgejodomain}"
    export DBPASSWORD="${var.instance-0001-cloudinit-dbpasswd}"
    
    # Create directories
    mkdir -p $PATHGITSETUP/forgejo-$GITDOMAIN
    mkdir $PATHGITSETUP/forgejo-$GITDOMAIN/forgejo
    mkdir $PATHGITSETUP/forgejo-$GITDOMAIN/postgres
    
    # Docker compose
    cat <<EOF > $PATHGITSETUP/forgejo-$GITDOMAIN/docker-compose.yaml
    networks:
      forgejo:
        external: false
    
    services:
      forgejo-0001:
        image: codeberg.org/forgejo/forgejo:10
        container_name: forgejo-0001
        environment:
          - USER_UID=1000
          - USER_GID=1000
          - FORGEJO__repository__ENABLE_PUSH_CREATE_USER=true
          - FORGEJO__repository__ENABLE_PUSH_CREATE_ORG=true
          - FORGEJO__database__DB_TYPE=postgres
          - FORGEJO__database__HOST=postgres-0001:5432
          - FORGEJO__database__NAME=forgejo
          - FORGEJO__database__USER=forgejo
          - FORGEJO__database__PASSWD=$DBPASSWORD
          - FORGEJO__server__DOMAIN=$GITDOMAIN
          - FORGEJO__server__PROTOCOL=https
          - FORGEJO__server__ENABLE_ACME=true
          - FORGEJO__server__ACME_ACCEPTTOS=true
          - FORGEJO__server__HTTP_PORT=443
        restart: always
        networks:
          - forgejo
        volumes:
          - $PATHGITSETUP/forgejo-$GITDOMAIN/forgejo:/data
          - /etc/timezone:/etc/timezone:ro
          - /etc/localtime:/etc/localtime:ro
        ports:
          - '80:80'
          - '222:22'
          - '443:443'
        depends_on:
          - postgres-0001
    
      postgres-0001:
        image: postgres:14
        container_name: postgres-0001
        restart: always
        environment:
          - POSTGRES_USER=forgejo
          - POSTGRES_PASSWORD=$DBPASSWORD
          - POSTGRES_DB=forgejo
        networks:
          - forgejo
        volumes:
          - $PATHGITSETUP/forgejo-$GITDOMAIN/postgres:/var/lib/postgresql/data
    EOF
    
    docker compose -f $PATHGITSETUP/forgejo-$GITDOMAIN/docker-compose.yaml up -d
  EOF2EOF
}

resource "openstack_networking_floatingip_v2" "flip-0001" {
  pool = var.flip-0001-poolname
}

resource "openstack_networking_floatingip_associate_v2" "flip-0001-assoc-0001" {
  floating_ip = openstack_networking_floatingip_v2.flip-0001.address
  port_id = openstack_networking_port_v2.network-0001-port-0001.id
}
