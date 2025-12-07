module "vpc" {
  source     = "../../modules/vpc"
  name       = "demo"
  cidr_block = "10.10.0.0/16"
  azs        = ["us-east-1a", "us-east-1b"]
}

module "ec2" {
  source        = "../../modules/ec2_app"
  name          = "demo-app"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets[0]
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
}

resource "aws_security_group" "rds" {
  name        = "demo-rds-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow DB access from app instances"
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.ec2.security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "rds" {
  source            = "../../modules/rds"
  name              = "demo-db"
  subnet_ids        = module.vpc.private_subnets
  password          = var.db_password
  security_group_id = aws_security_group.rds.id
}

module "frontend" {
  source      = "../../modules/cloudfront"
  bucket_name = var.frontend_bucket
}

output "instance_ip" {
  value = module.ec2.instance_public_ip
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "cdn_domain" {
  value = module.frontend.cloudfront_domain
}

output "frontend_bucket" {
  value = module.frontend.s3_bucket
}

