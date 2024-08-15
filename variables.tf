variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "hub_vpc_cidr" {
  description = "CIDR block for the Hub VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "prod_vpc_cidr" {
  description = "CIDR block for the Prod VPC"
  type        = string
  default     = "10.1.0.0/16"
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

variable "prod_private_subnets" {
  description = "Private subnets for the Prod VPC"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0c2af51e265bd5e0e"
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
  default     = "terraform-code-production-key"
}
