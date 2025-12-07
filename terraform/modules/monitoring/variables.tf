variable "name" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "cpu_threshold" {
  type    = number
  default = 80
}
