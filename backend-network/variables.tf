variable "region" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1"
}


variable "backend_vpc_address_space" {
  description = "The CIDR block for the backend VPC."
  default     = "10.1.0.0/16"
}

variable "backend_prefix" {
  description = "The prefix for the backend resources."
  default     = "backend"
}

variable "backend_environment" {
  description = "The environment for the backend resources."
  default     = "dev"
}

variable "backend_public_subnet_cidr" {
  description = "The CIDR block for the backend public subnets."
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "backend_private_subnet_cidr" {
  description = "The CIDR block for the backend private subnets."
  default     = ["10.1.100.0/24", "10.1.101.0/24", "10.1.102.0/24"]
}





