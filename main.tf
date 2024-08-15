provider "aws" {
  region = var.region
}

# Hub VPC
module "hub_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "Hub-VPC"
  cidr = var.hub_vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.hub_public_subnets
  private_subnets = var.hub_private_subnets
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"  # Replacing deprecated vpc argument
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(module.hub_vpc.public_subnets, 0)

  tags = {
    Name = "nat-gateway"
  }
}

# Prod VPC
module "prod_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "Prod-VPC"
  cidr = var.prod_vpc_cidr

  azs              = var.availability_zones
  private_subnets  = var.prod_private_subnets
  enable_nat_gateway = false
  single_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

# VPC Peering
resource "aws_vpc_peering_connection" "hub_prod" {
  vpc_id      = module.hub_vpc.vpc_id
  peer_vpc_id = module.prod_vpc.vpc_id
  auto_accept = true

  tags = {
    Name = "Hub-Prod-Peering"
  }
}

# Route tables for Hub VPC to Prod VPC
resource "aws_route" "hub_to_prod" {
  route_table_id            = element(module.hub_vpc.public_route_table_ids, 0)
  destination_cidr_block    = var.prod_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_prod.id
}

# Route tables for Prod VPC to Hub VPC and Internet
resource "aws_route" "prod_to_hub" {
  count                     = length(module.prod_vpc.private_route_table_ids)
  route_table_id            = element(module.prod_vpc.private_route_table_ids, count.index)
  destination_cidr_block    = var.hub_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_prod.id
}


# Security Groups for Hub VPC
resource "aws_security_group" "hub_security_group" {
  name   = "hub-security-group"
  vpc_id = module.hub_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Hub-Security-Group"
  }
}

# Security Groups for Prod VPC allowing ingress from Hub VPC's public LB subnet
resource "aws_security_group" "prod_security_group" {
  name   = "prod-security-group"
  vpc_id = module.prod_vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.hub_public_subnets[0]]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.hub_public_subnets[0]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prod-Security-Group"
  }
}

# Additional Security Group for SSH allowing ingress from Hub-admin-public-SN
resource "aws_security_group" "hub_admin_sg" {
  name   = "hub-admin-sg"
  vpc_id = module.hub_vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Hub-Admin-SG"
  }
}

resource "aws_security_group" "prod_private_sg" {
  name   = "prod-private-sg"
  vpc_id = module.prod_vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"] # Adjust the CIDR block to the specific subnet
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.hub_public_subnets[0]]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.hub_public_subnets[0]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Prod-Private-SG"
  }
}

# EC2 Instances
module "jump_server" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name           = "jump-server"
  ami            = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name

  vpc_security_group_ids = [aws_security_group.hub_security_group.id, aws_security_group.hub_admin_sg.id]
  subnet_id              = module.hub_vpc.public_subnets[1]

  tags = {
    Name = "jump-server"
  }
}

module "bastion_server" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.0"

  name           = "bastion-server"
  ami            = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name

  vpc_security_group_ids = [aws_security_group.prod_private_sg.id, aws_security_group.prod_security_group.id]
  subnet_id              = module.prod_vpc.private_subnets[0]

  tags = {
    Name = "bastion-server"
  }
}
