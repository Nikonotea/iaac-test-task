resource "aws_security_group" "app" {
  name        = "${var.name}-sg"
  vpc_id      = var.vpc_id
  description = "Allow HTTP/SSH"
  dynamic "ingress" {
    for_each = var.allowed_ssh_cidrs
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.name}-sg" })
}

resource "aws_instance" "app" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  user_data              = file(var.user_data_file)

  tags = merge(var.tags, { Name = "${var.name}-ec2" })
}

resource "aws_iam_role" "instance_role" {
  name               = "${var.name}-instance-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.instance_role.name
}

