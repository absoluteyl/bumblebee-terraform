# BumbleBee Terraform

Terraform for BumbleBee, this terraform will create the following:

  - 1 VPC
  - 2 Public Subnets
  - 4 Private Subnets (2 for EC2/ECS, 2 for RDS)
  - 2 Route Tables (1 for Public Subnets, 1 for Private Subnets)
  - IAM Roles for EC2, ECS
  - S3 Bucket for logs
  - Security Groups for ALB, EC2, ECS Services and RDS
  - ALB
  - ECS Cluster, including:
    - Auto Scaling Group using t3.micro spot instance
    - Target Groups
    - BumbleBee Service

## Commands

- Plan

``` sh
bin/terraform plan prod
```

- Apply

``` sh
bin/terraform apply prod
```

- Refresh

``` sh
bin/terraform refresh prod
```
