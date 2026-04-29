# aws_infra/iam/main.tf
# EC2 인스턴스에서 S3 버킷과 SSM을 사용할 수 있도록 IAM Role을 생성하고, Code Deploy 서비스 역할도 추가로 생성
# EC2 인스턴스가 사용할 수 있는 신분(역할) 생성 (EC2 전용 IAM Role 생성)
resource "aws_iam_role" "aws05_ec2_role" {
  name = "${var.prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
# SSM 접근 권한
resource "aws_iam_role_policy_attachment" "aws05_ssm_attach" {
  role       = aws_iam_role.aws05_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# S3 접근 권한
resource "aws_iam_role_policy_attachment" "aws05_s3_attach" {
  role       = aws_iam_role.aws05_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
# EC2 인스턴스 프로파일
resource "aws_iam_instance_profile" "aws05_ec2_instance_profile" {
  name = "${var.prefix}-ec2-instance-profile"
  role = aws_iam_role.aws05_ec2_role.name
}

# Code Deploy Service Role
resource "aws_iam_role" "aws05_codedeploy_service_role" {
  name = "${var.prefix}-codedeploy-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}
#Code Deploy Service Role에 AWSCodeDeployRole 정책 연결
resource "aws_iam_role_policy_attachment" "aws05_codedeploy_service_attach" {
  role       = aws_iam_role.aws05_codedeploy_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# 출력
output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.aws05_ec2_instance_profile.name
}
output "codedeploy_service_role_arn" {
  value = aws_iam_role.aws05_codedeploy_service_role.arn
}
