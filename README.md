# production-ready-terraform
Production Ready Terraform

## Set up
- Initialize project
```
cd step-by-step/dev
terraform init
```

- Create Certificate authority, server key/cert, and client key/cert following [this guide](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html). (see "Mutual authentication")

- Deploy project
```
terraform apply
```
