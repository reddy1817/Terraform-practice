output "public_subnet_ids" {
  value = aws_subnet.public["us-east-1a"].id
}