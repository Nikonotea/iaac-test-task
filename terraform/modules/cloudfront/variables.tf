variable "bucket_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "force_destroy" {
  type    = bool
  default = true
}
