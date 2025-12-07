variable "bucket_name" {
  type = string
}

variable "dynamo_table" {
  type    = string
  default = "terraform-locks"
}
