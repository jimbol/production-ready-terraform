output "test_ec2_id" {
  description = "test ec2 id"
  value = aws_instance.test_server[*].id
}
