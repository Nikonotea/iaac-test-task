variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "allowed_ssh_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "allowed_http_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "user_data_file" {
  type    = string
  default = "templates/user-data.sh.tpl"
}
