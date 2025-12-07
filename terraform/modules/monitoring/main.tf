resource "aws_sns_topic" "alerts" {
  name = "${var.name}-alerts"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.name}-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = var.instance_id
  }
}
