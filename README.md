# production-ready-terraform
Production Ready Terraform

## Set up
- Install AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html
- Initialize project
```
cd example/dev
terraform init
```

- Create Certificate authority, server key/cert, and client key/cert
  - Follow this guide: [docs/create-certificate-authority.md](create-certificate-authority.md)
  - More reading: [AWS Docs](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html)

- Deploy project
```
terraform apply
```
