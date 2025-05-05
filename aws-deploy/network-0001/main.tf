terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.97.0"
    }
  }
}

variable "aws_region" { type = string }

variable "vpc-0001-cidr" {
  type = string
  default = "172.16.0.0/16"
}

variable "vpc-0001-name" {
  type = string
  default = "vpc-0001.aws-cloud-0001.vty-valentin-vty.net"
}

provider "aws" {
  region = var.aws_region
}


resource "aws_vpc" "vpc-0001" {
  cidr_block = var.vpc-0001-cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc-0001-name
  }
}

resource "aws_subnet" "vpc-0001-subnet-0001" {
  vpc_id = aws_vpc.vpc-0001.id
  cidr_block = cidrsubnet(var.vpc-0001-cidr, 8, 1)
  ipv6_cidr_block = cidrsubnet(var.vpc-0001-cidr-ipv6, 16, 1)
}

3 more subnets
4 secuirty groups 
1 igw
multiple RTBs