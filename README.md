# Next steps
- Site to site VPN

- Additional services
  - Kubernetes Cluster
  - API Gateway and Lambdas
  - RDS
- Create presentation
  - Introduction
  - Create diagrams
  - Create tests at each step
  - Create engagement slides


# production-ready-terraform
Production Ready Terraform

## Set up
- Initialize project
```
cd complete/dev
terraform init
```

- Create Certificate authority, server key/cert, and client key/cert following [this guide](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication.html). (see "Mutual authentication")

- Deploy project
```
terraform apply
```
