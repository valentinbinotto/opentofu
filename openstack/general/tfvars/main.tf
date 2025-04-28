terraform {
  required_version = ">= 1.4.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.1"
    }
  }
}

variable "os_auth_url" { type = string }
variable "os_project_id" { type = string }
variable "os_application_credential_id" { type = string }
variable "os_application_credential_secret" {
  type      = string
  sensitive = true
}

variable "network-0001-name" {
  type = string
  default = "network-0001.os-cloud-0001.vty-valentin-vty.net"
}

provider "openstack" {
  auth_url                      = var.os_auth_url
  tenant_id                     = var.os_project_id
  application_credential_id     = var.os_application_credential_id
  application_credential_secret = var.os_application_credential_secret
}

resource openstack_networking_network_v2 "network-0001" {
  name = var.network-0001-name}

