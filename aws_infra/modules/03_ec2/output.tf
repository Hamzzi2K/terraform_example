output "ami_id" {
  value = aws_ami_from_instance.aws05_ami.id
}
output "ami_arn" {
  value = aws_ami_from_instance.aws05_ami.arn
}
output "ami_name" {
  value = aws_ami_from_instance.aws05_ami.name
}
