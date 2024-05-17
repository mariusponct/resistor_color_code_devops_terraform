
//create auto scaling target
resource "aws_appautoscaling_target" "rcc-ecs_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.rcc-cluster.name}/${aws_ecs_service.rcc-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 1
  max_capacity       = 3
}

//create autoscaling policy "up""
resource "aws_appautoscaling_policy" "rcc-up" {
  name               = "scale_up"
  service_namespace  = aws_appautoscaling_target.rcc-ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.rcc-ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.rcc-ecs_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
  depends_on = [aws_appautoscaling_target.rcc-ecs_target]
}

//create autoscaling policy "down"
resource "aws_appautoscaling_policy" "rcc-down" {
  name               = "scale_down"
  service_namespace  = aws_appautoscaling_target.rcc-ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.rcc-ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.rcc-ecs_target.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
  depends_on = [aws_appautoscaling_target.rcc-ecs_target]
}

//create alarm that triggers the "up" policy
resource "aws_cloudwatch_metric_alarm" "rcc-cpu_high" {
  alarm_name          = "rcc-cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 60
  alarm_description   = "High CPU utilization"

  dimensions = {

    ClusterName = aws_ecs_cluster.rcc-cluster.name
    ServiceName = aws_ecs_service.rcc-service.name
  }
  alarm_actions = [aws_appautoscaling_policy.rcc-up.arn]
}

//create alarm that triggers the "down" policy
resource "aws_cloudwatch_metric_alarm" "rcc-cpu_low" {
  alarm_name          = "rcc-cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "Low CPU utilization"

  dimensions = {

    ClusterName = aws_ecs_cluster.rcc-cluster.name
    ServiceName = aws_ecs_service.rcc-service.name
  }
  alarm_actions = [aws_appautoscaling_policy.rcc-down.arn]
}
