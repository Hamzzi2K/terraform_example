# aws_infra/alb/data.tf
# AWS ALB 관련 데이터 소스 정의
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = "network/terraform.tfstate"
    region = var.region
  }
}
