resource "aws_security_group" "elb" {
  name        = "elb"
  description = "Web backends security policies."
  vpc_id      = aws_vpc.IS_VPC1.id

  ingress { # HTTP
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # HTTP
    from_port   = 80
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "elb" {
  name     = "terraform-elb"
  subnets  = ["${aws_subnet.aws-1-subnet-private.id}", "${aws_subnet.aws-2-subnet-private.id}", "${aws_subnet.aws-3-subnet-public.id}"]
  internal = false

  listener {
    instance_port     = 8888
    instance_protocol = "http"
    lb_port           = 8888
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 8888
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8888/"
    interval            = 30
  }

  security_groups             = ["${aws_security_group.elb.id}"]
  instances                   = ["${aws_instance.web-1.id}", "${aws_instance.web-2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 30
  connection_draining         = true
  connection_draining_timeout = 30

  tags = {
    Name = "terraform-elb"
  }
}

output "elb_instances" {
  value = ["${aws_elb.elb.instances}"]
}

output "elb_public_dns_name" {
  value = ["${aws_elb.elb.dns_name}"]
}
