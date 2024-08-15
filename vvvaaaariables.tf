variable "region" {
  description = "The AWS region to deploy to"
  default     = "ap-south-1"
}

variable "hub_vpc_cidr" {
  description = "CIDR block for the Hub VPC"
  default     = "10.0.0.0/16"
}

variable "prod_vpc_cidr" {
  description = "CIDR block for the Prod VPC"
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "hub_public_subnets" {
  description = "Public subnets for the Hub VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "hub_private_subnets" {
  description = "Private subnets for the Hub VPC"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "hub_public_subnets_cidr" {
  description = "CIDR blocks of public subnets for the Hub VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "hub_private_subnets_cidr" {
  description = "CIDR blocks of private subnets for the Hub VPC"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "prod_private_subnets" {
  description = "Private subnets for the Prod VPC"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0c2af51e265bd5e0e"  # Example AMI ID
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key name for EC2 instances"
  default     = "terraform-code-production-key"
}
