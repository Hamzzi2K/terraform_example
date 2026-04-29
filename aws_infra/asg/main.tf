# aws_infra/asg/main.tf
# 시작템플릿
resource "aws_launch_template" "aws05_launch_template" {
  name_prefix   = "${var.prefix}-launch-template-"
  image_id      = data.aws_ami.aws05_instance_ami.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = data.aws_iam_instance_profile.aws05_ec2_instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = "false"
    security_groups = [
      data.aws_security_group.aws05_ssh_sg.id,
      data.aws_security_group.aws05_http_sg.id,
    ]
    subnet_id = element(data.aws_subnets.aws05_private_subnets.ids, count.index)
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.prefix}-instance"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

# 오토스케일링 그룹
resource "aws_autoscaling_group" "aws05_asg" {
  name             = "${var.prefix}-asg"
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
  launch_template {
    id      = aws_launch_template.aws05_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier       = data.aws_subnets.aws05_private_subnets.ids
  target_group_arns         = [data.aws_lb_target_group.aws05_was_group.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
}

# 대상그룹 연결
