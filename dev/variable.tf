variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "ubuntu-server"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.xlarge"
}

variable "key_pair_name" {
  description = "AWS key pair name for SSH access"
  type        = string
  default     = "orca"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 200
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "development"
}

variable "ubuntu" {
    description = "Ubuntu ami image"
    type = string   
    default = "ami-020cba7c55df1f615"
}