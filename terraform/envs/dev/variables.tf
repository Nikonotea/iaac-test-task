variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami" {
  type    = string
  default = "ami-0c2b8ca1dad447f8a" # Amazon Linux 2 (replace per region)
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = ""
}

variable "db_password" {
  type = string
}

variable "frontend_bucket" {
  type    = string
  default = "demo-frontend-bucket-12345"
}
