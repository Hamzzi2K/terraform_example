output "ec2_instance_profile_id" {
  value = aws_iam_instance_profile.aws05_ec2_instance_profile.id
}
output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.aws05_ec2_instance_profile.name
}

output "codedeploy_service_role_arn" {
  value = aws_iam_role.aws05_codedeploy_service_role.arn
}
