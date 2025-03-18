# AWS Provider Configuration
provider "aws" {
  region = "ap-southeast-1"
}

# VPC Resource
# Creates a Virtual Private Cloud with CIDR block 10.0.0.0/16
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "MyVPC"
    Environment = "Production"
    ManagedBy = "Terraform"
  }
}

# Public Subnet Resource
# Creates a public subnet with auto-assigned public IPs in availability zone ap-southeast-1a
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
  
  tags = {
    Name = "Public-Subnet"
    Type = "Public"
    Environment = "Production"
    ManagedBy = "Terraform"
  }
}

# Private Subnet Resource
# Creates a private subnet with no public IP assignment in availability zone ap-southeast-1a
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"
  
  tags = {
    Name = "Private-Subnet"
    Type = "Private"
    Environment = "Production"
    ManagedBy = "Terraform"
  }
}

# Internet Gateway
# Provides outbound and inbound internet access for resources in the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  
  tags = {
    Name = "VPC-IGW"
    Environment = "Production"
    ManagedBy = "Terraform"
  }
}

# Public Route Table
# Handles traffic routing for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  
  tags = {
    Name = "Public-Route-Table"
    Type = "Public"
    Environment = "Production"
    ManagedBy = "Terraform"
  }
}

# Public Route
# Enables internet access by routing all outbound traffic (0.0.0.0/0) to the Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Public Route Table Association
# Associates the public subnet with the public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP for NAT Gateway
# Allocates a static public IP address for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  
  tags = {
    Name = "NAT-Gateway-EIP"
    Environment = "Production"
    ManagedBy = "Terraform"
  }
}

# NAT Gateway
# Enables outbound internet access for resources in the private subnet while preventing inbound access
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.nat_eip.id
  
  tags = {
    Name = "VPC-NAT-Gateway"
    Environment = "Production"
    ManagedBy = "Terraform"
  }
}

# Private Route Table
# Handles traffic routing for the private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  
  tags = {
    Name = "Private-Route-Table"
    Type = "Private"
    Environment = "Production"
    ManagedBy = "Terraform"
  }
}

# Private Route
# Routes all outbound traffic from private subnet to the NAT Gateway
resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Private Route Table Association
# Associates the private subnet with the private route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}