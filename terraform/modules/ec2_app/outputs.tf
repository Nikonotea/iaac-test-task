output "instance_id" {
  value = aws_instance.app.id
}

output "instance_public_ip" {
  value = aws_instance.app.public_ip
}

output "instance_profile" {
  value = aws_iam_instance_profile.instance_profile.name
}

output "security_group_id" {
  value = aws_security_group.app.id
}
