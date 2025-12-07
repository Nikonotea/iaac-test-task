// Example S3 backend configuration. Uncomment and fill values to enable remote state.
/*
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "iaac-test-task/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-terraform-locks"
    encrypt        = true
  }
}
*/
