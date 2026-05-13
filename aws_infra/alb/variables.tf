# aws_infra/alb/variables.tf
variable "remote_state_bucket" { type = string }
variable "region" { type = string }
variable "prefix" { type = string }
variable "certificate_arn" { type = string }
