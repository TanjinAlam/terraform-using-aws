# AWS VPC Terraform Module

This Terraform module creates a complete Virtual Private Cloud (VPC) infrastructure on AWS including public and private subnets, internet gateway, NAT gateway, and all necessary route tables and associations.

## Architecture

The module creates the following resources:

- A VPC with configurable CIDR block
- Multiple public subnets across different availability zones
- Multiple private subnets across different availability zones
- Internet Gateway for public internet access
- NAT Gateway (optional) for private subnet outbound internet access
- Route tables for both public and private subnets
- All necessary route associations

## Instructions

### Start the Terraform Project

1. Initialize the Terraform working directory:

   ```sh
   terraform init
   ```

2. Review the Terraform execution plan:

   ```sh
   terraform plan
   ```

3. Apply the Terraform configuration to create the resources:
   ```sh
   terraform apply
   ```
4. After applying the configuration, you can view the output values (e.g., VPC ID, subnet IDs) with:
   ```sh
   terraform output
   ```

### Destroy the Terraform Project

To destroy the resources created by this Terraform configuration, run the following command:

```sh
terraform destroy
```

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc/v1"

  vpc_name                      = "production-vpc"
  cidr_block                    = "10.0.0.0/16"
  enable_dns_support            = true
  enable_dns_hostnames          = true
  public_subnet_count           = 3
  public_subnet_additional_bits = 4
  private_subnet_count          = 3
  private_subnet_additional_bits = 4
  nat_gateway                   = true

  default_tags = {
    Environment = "production"
    Terraform   = "true"
    Project     = "my-project"
  }

  public_subnet_tags = {
    Tier = "public"
  }

  private_subnet_tags = {
    Tier = "private"
  }
}
```

## Requirements

| Name      | Version  |
| --------- | -------- |
| terraform | >= 1.0.0 |
| aws       | >= 4.0.0 |

## Inputs

| Name                           | Description                                    | Type          | Default         | Required |
| ------------------------------ | ---------------------------------------------- | ------------- | --------------- | :------: |
| nat_gateway                    | A boolean flag to deploy NAT Gateway.          | `bool`        | `false`         |    no    |
| vpc_name                       | Name of the VPC.                               | `string`      | `"my-vpc"`      |    no    |
| cidr_block                     | The IPv4 CIDR block for the VPC.               | `string`      | `"10.0.0.0/16"` |    no    |
| enable_dns_support             | Enable/disable DNS support in the VPC.         | `bool`        | `true`          |    no    |
| enable_dns_hostnames           | Enable/disable DNS hostnames in the VPC.       | `bool`        | `false`         |    no    |
| default_tags                   | A map of tags to add to all resources.         | `map(string)` | `{}`            |    no    |
| public_subnet_count            | Number of Public subnets.                      | `number`      | `3`             |    no    |
| public_subnet_additional_bits  | Number of additional bits for public subnets.  | `number`      | `4`             |    no    |
| public_subnet_tags             | A map of tags to add to all public subnets.    | `map(string)` | `{}`            |    no    |
| private_subnet_count           | Number of Private subnets.                     | `number`      | `3`             |    no    |
| private_subnet_additional_bits | Number of additional bits for private subnets. | `number`      | `4`             |    no    |
| private_subnet_tags            | A map of tags to add to all private subnets.   | `map(string)` | `{}`            |    no    |

## Outputs

| Name                     | Description                          |
| ------------------------ | ------------------------------------ |
| vpc_id                   | The ID of the VPC.                   |
| list_of_az               | List of availability zones.          |
| public_subnets           | List of public subnet IDs.           |
| private_subnets          | List of private subnet IDs.          |
| aws_internet_gateway     | The Internet Gateway.                |
| aws_route_table_public   | The ID of the public route table.    |
| aws_route_table_private  | The ID of the private route table.   |
| nat_gateway_ipv4_address | The IPv4 address of the NAT Gateway. |

## CIDR Calculation

This module uses Terraform's `cidrsubnet` function to automatically calculate subnet CIDR blocks:

- Public subnets use subnet numbers 0 to (public_subnet_count - 1)
- Private subnets use subnet numbers (public_subnet_count) to (public_subnet_count + private_subnet_count - 1)

## Network Diagram

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e6f7ff', 'primaryTextColor': '#005cc5', 'primaryBorderColor': '#005cc5', 'lineColor': '#004080', 'secondaryColor': '#fafafa', 'tertiaryColor': '#f2f2f2'}}}%%
flowchart TB
    classDef vpcClass fill:#e6f7ff,stroke:#005cc5,stroke-width:2px,color:#005cc5
    classDef publicSubnetClass fill:#c2f0c2,stroke:#2ca02c,stroke-width:2px,color:#2ca02c
    classDef privateSubnetClass fill:#ffcccc,stroke:#d62728,stroke-width:2px,color:#d62728
    classDef igwClass fill:#ffffcc,stroke:#ff7f0e,stroke-width:2px,color:#ff7f0e
    classDef natClass fill:#f2d9f2,stroke:#9467bd,stroke-width:2px,color:#9467bd
    classDef rtClass fill:#ffebcc,stroke:#e69500,stroke-width:2px,color:#e69500
    classDef routeClass fill:#d9f2f2,stroke:#17becf,stroke-width:2px,color:#17becf
    classDef assocClass fill:#e6ccff,stroke:#7f00ff,stroke-width:2px,color:#7f00ff

    VPC["AWS VPC<br>CIDR: 10.0.0.0/16"]
    IGW["Internet Gateway"]
    RT_PUB["Public Route Table"]
    RT_PRIV["Private Route Table"]

    subgraph PublicSubnets["Public Subnets"]
        SUB_PUB1["Public Subnet 1<br>AZ: us-east-1a<br>CIDR: 10.0.0.0/20"]
        SUB_PUB2["Public Subnet 2<br>AZ: us-east-1b<br>CIDR: 10.0.16.0/20"]
        SUB_PUB3["Public Subnet 3<br>AZ: us-east-1c<br>CIDR: 10.0.32.0/20"]
    end

    subgraph PrivateSubnets["Private Subnets"]
        SUB_PRIV1["Private Subnet 1<br>AZ: us-east-1a<br>CIDR: 10.0.48.0/20"]
        SUB_PRIV2["Private Subnet 2<br>AZ: us-east-1b<br>CIDR: 10.0.64.0/20"]
        SUB_PRIV3["Private Subnet 3<br>AZ: us-east-1c<br>CIDR: 10.0.80.0/20"]
    end

    NAT["NAT Gateway<br>(In Public Subnet 1)"]
    EIP["Elastic IP"]

    VPC --> IGW

    IGW -- "Route 0.0.0.0/0" --> RT_PUB

    RT_PUB -- "Route Table Association" --> SUB_PUB1
    RT_PUB -- "Route Table Association" --> SUB_PUB2
    RT_PUB -- "Route Table Association" --> SUB_PUB3

    SUB_PUB1 -- "Hosts" --> NAT
    EIP -- "Assigned to" --> NAT

    NAT -- "Route 0.0.0.0/0" --> RT_PRIV

    RT_PRIV -- "Route Table Association" --> SUB_PRIV1
    RT_PRIV -- "Route Table Association" --> SUB_PRIV2
    RT_PRIV -- "Route Table Association" --> SUB_PRIV3

    VPC:::vpcClass
    IGW:::igwClass
    NAT:::natClass
    EIP:::natClass
    RT_PUB:::rtClass
    RT_PRIV:::rtClass
    SUB_PUB1:::publicSubnetClass
    SUB_PUB2:::publicSubnetClass
    SUB_PUB3:::publicSubnetClass
    SUB_PRIV1:::privateSubnetClass
    SUB_PRIV2:::privateSubnetClass
    SUB_PRIV3:::privateSubnetClass
    PublicSubnets:::publicSubnetClass
    PrivateSubnets:::privateSubnetClass
```

## Traffic Flow

1. **Internet to Public Subnets**: Traffic flows from the internet through the Internet Gateway to resources in public subnets.

2. **Public Subnets to Internet**: Resources in public subnets use the Internet Gateway as their default route to send traffic to the internet.

3. **Private Subnets to Internet**: Resources in private subnets send outbound traffic through the NAT Gateway (which resides in a public subnet), which then forwards the traffic to the Internet Gateway.

4. **Internet to Private Subnets**: Direct inbound traffic from the internet to private subnets is not allowed. Traffic must first go through resources in the public subnets.

## Best Practices

- Use private subnets for databases, application servers, and other resources that don't need direct internet access
- Use public subnets for load balancers, bastion hosts, and other internet-facing resources
- Enable NAT Gateway only when resources in private subnets need outbound internet access
- Consider using multiple NAT Gateways (one per AZ) for high-availability production environments
