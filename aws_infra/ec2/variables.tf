# aws_infra/ec2/variables.tf
variable "remote_state_bucket" { type = string }
variable "region" { type = string }
variable "prefix" { type = string }
variable "key_name" { type = string }
variable "instance_type" { type = string }
variable "ami_id" { type = string }
