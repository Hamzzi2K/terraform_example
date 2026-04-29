# aws_infra/alb/main.tf
# ALB 생성
resource "aws_lb" "aws05_alb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.aws05_http_sg.id]
  subnets            = data.aws_subnets.aws05_public_subnets.ids

  tags = {
    Name = "${var.prefix}-alb"
  }
}

#was 대상 그룹 생성
resource "aws_lb_target_group" "aws05_alb_was_group" {
  name     = "${var.prefix}-alb-was-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.aws05_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP" # "traffic-port"로 설정하면 ALB(대상그룹)가 사용하는 포트에서 헬스체크를 수행
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Name = "${var.prefix}-alb-was-group"
  }
}
#jenkins 대상 그룹 생성
resource "aws_lb_target_group" "aws05_alb_jenkins_group" {
  name     = "${var.prefix}-alb-jenkins-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.aws05_vpc.id
  health_check {
    path                = "/login" # Jenkins의 로그인 페이지를 헬스체크 경로로 설정
    protocol            = "HTTP"   # "traffic-port"로 설정하면 ALB(대상그룹)가 사용하는 포트에서 헬스체크를 수행
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = {
    Name = "${var.prefix}-alb-jenkins-group"
  }
}
#default 리스너 설정
resource "aws_lb_listener" "aws05_alb_listener" {
  load_balancer_arn = aws_lb.aws05_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: Not Found"
      status_code  = "404"
    }
  }
}
#was 리스너 규칙
resource "aws_lb_listener_rule" "aws05_alb_was_rule" {
  listener_arn = aws_lb_listener.aws05_alb_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws05_alb_was_group.arn
  }

  condition {
    host_header {
      values = ["${var.prefix}-was.busanit.com"]
    }
  }
}
#jenkins 리스너 규칙
resource "aws_lb_listener_rule" "aws05_alb_jenkins_rule" {
  listener_arn = aws_lb_listener.aws05_alb_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws05_alb_jenkins_group.arn
  }

  condition {
    host_header {
      values = ["${var.prefix}-jenkins.busanit.com"]
    }
  }
}
