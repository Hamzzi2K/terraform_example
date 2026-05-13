output "lb_was_tg_id" {
  value = aws_lb_target_group.aws05_alb_was_group.id
}
output "lb_was_tg_arn" {
  value = aws_lb_target_group.aws05_alb_was_group.arn
}
output "lb_jenkins_tg_id" {
  value = aws_lb_target_group.aws05_alb_jenkins_group.id
}
output "lb_jenkins_tg_arn" {
  value = aws_lb_target_group.aws05_alb_jenkins_group.arn
}
