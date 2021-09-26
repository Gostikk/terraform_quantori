resource "aws_launch_configuration" "alc" {
  name_prefix = "alc-"

  image_id      = "ami-0c46192d65be87c42"
  instance_type = "t2.micro"
  key_name      = "lastkeys"

  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "asg" {
  name = "${aws_launch_configuration.alc.name}-asg"

  min_size         = 0
  desired_capacity = 0
  max_size         = 3

  launch_configuration = aws_launch_configuration.alc.name

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = ["${aws_subnet.aws-2-subnet-private.id}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "asg"
    propagate_at_launch = true
  }

}

resource "aws_autoscalingplans_scaling_plan" "example" {
  name = "cpu_utlisation_scaling"

  application_source {
    tag_filter {
      key    = "application"
      values = ["example"]
    }
  }

  scaling_instruction {
    max_capacity       = 3
    min_capacity       = 0
    resource_id        = format("autoScalingGroup/%s", aws_autoscaling_group.asg.name)
    scalable_dimension = "autoscaling:autoScalingGroup:DesiredCapacity"
    service_namespace  = "autoscaling"

    target_tracking_configuration {
      predefined_scaling_metric_specification {
        predefined_scaling_metric_type = "ASGAverageCPUUtilization"
      }

      target_value = 70
    }
  }
}