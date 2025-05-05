#!/bin/bash

apt update
apt install -y git curl wget openstack-clients vim awscli
echo "vbhost" > /etc/hostname
hostname vbhost