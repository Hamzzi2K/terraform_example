# aws_infra/alb/data.tf
# AWS ALB 관련 데이터 소스 정의
data "aws_vpc" "aws05_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-vpc"]
  }
}
data "aws_subnets" "aws05_public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-public-subnet-*"]
  }
}
data "aws_security_group" "aws05_http_sg" {
  filter {
    name   = "tag:Name"
    values = ["${var.prefix}-http-sg"]
  }
}

