resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "this" {
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.this.id
  publicly_accessible    = false
  vpc_security_group_ids = [var.security_group_id]
  copy_tags_to_snapshot  = true
  tags                   = merge(var.tags, { Name = "${var.name}-rds" })
}


