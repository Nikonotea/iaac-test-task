variable "name" {
  type        = string
  description = "Base name for resources"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "public_subnet_mask" {
  type    = number
  default = 24
}

variable "private_subnet_mask" {
  type    = number
  default = 24
}
