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

variable "domain-0001-name" {
  type = string
  default = "os-cloud-0001.vty-valentin-vty.net"
}

variable "domain-0001-project-0001-name" {
  type = string
  default = "project-0001.os-cloud-0001"
}

variable "domain-0001-user-0001-name" {
  type = string
  default = "valentin"
}

variable "domain-0001-user-0001-email" {
  type = string
  default = "valentin@vty-valentin-vty.oscloud"
}

variable "domain-0001-user-0001-password" {
  type = string
  sensitive = true
}

variable "domain-0001-role-0001-name" {
  type = string
  default = "rl-0001.os-cloud-0001"
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


resource "openstack_identity_project_v3" "domain-0001" {
  name = var.domain-0001-name
  is_domain = true
  enabled = true
}

resource "openstack_identity_project_v3" "domain-0001-project-0001" {
  name = var.domain-0001-project-0001-name
  is_domain = false
  domain_id = openstack_identity_project_v3.domain-0001.id
}

resource "openstack_identity_user_v3" "domain-0001-user-0001" {
  name = var.domain-0001-user-0001-name
  domain_id = openstack_identity_project_v3.domain-0001.id
  extra = {
    email = var.domain-0001-user-0001-email
  }
  enabled = true
  password = var.domain-0001-user-0001-password
}

resource "openstack_identity_role_v3" "domain-0001-role-0001" {
  name = var.domain-0001-role-0001-name
  domain_id = openstack_identity_project_v3.domain-0001.id
}

resource "openstack_identity_role_assignment_v3" "domain-0001-role-0001-assig-0001" {
  project_id = openstack_identity_project_v3.domain-0001-project-0001.id
  user_id = openstack_identity_user_v3.domain-0001-user-0001.id
  role_id = openstack_identity_role_v3.domain-0001-role-0001.id
}