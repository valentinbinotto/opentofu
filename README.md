# opentofu

## Deployment files
- [Amazon Web Services (AWS)](/aws-deploy/)

- [OpenStack (OS)](/os-deploy/)
    - [Bastion 0001 (SSH only with Floating IP)](/os-deploy/bastion-0001/)
    - [Bastion 0002 (No ingress traffic, Cloudflare Zero Trust)](/os-deploy/bastion-0002/)
    - [Forgejo 0001 (ACME, Lets Encrypt Certs)](/os-deploy/forgejo-0001/)
    - [FRR 0001 (FRR instance only, no network env)](/os-deploy/frr-0001/)
    - [IPFS 0001](/os-deploy/ipfs-0001/)
    - [Network 0001 (Int. Network with outside connectivity (Dual-Stack))](/os-deploy/network-0001/)
    - [Network 0002](/os-deploy/network-0002/)
    - [Network 0003](/os-deploy/network-0003/)
- [OVH](/ovh-deploy/)
- [Multi-Cloud](/multicloud-deploy/)

## Templates
- [Amazon Web Services (AWS)](/templates/aws/)
- [OpenStack (OS)](/templates/openstack/)
    - [Keystone](/templates/openstack/iam/)
        - [Full (Domain, Project, User, Role)](/templates/openstack/iam/full/)
        - [Domain only](/templates/openstack/iam/domain-only/)
    - [Nova](/templates/openstack/compute/)
    - [Neutron](/templates/openstack/networking/)
        - [Full (Int. and Ext. Network, Subnets, Routers, Security Groups)](/templates/openstack/networking/full/)
        - [Network only](/templates/openstack/networking/network-only/)
        - [Int. Network and Subnets](/templates/openstack/networking/int-net-subnet/)
        - [Int. Network, Subnets, Router](/templates/openstack/networking/int-net-subnet-extcon/)
    - [Storage](/templates/openstack/storage/)


- [OVH](/templates/ovh/)
- [Environment](/templates/env/)