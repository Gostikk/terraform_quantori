/*
  Swarm Servers
*/
resource "aws_security_group" "web" {
  name        = "web"
  description = "Web backends security policies."

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.vpc_1_cidr}", "${var.vpc_2_cidr}"]
  }
  ingress { # SSH
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_1_cidr}", "${var.vpc_2_cidr}"]
  }
  ingress { # HTTP
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_1_cidr}", "${var.vpc_2_cidr}"]
  }
  ingress { # Private subnet
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_1_cidr_private}", "${var.vpc_2_cidr_private}"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.vpc_1_cidr}", "${var.vpc_2_cidr}"]
  }
  egress { ## SSH/GIT
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { ## HTTP
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { ## DNS
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { # Private subnet
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_1_cidr_private}", "${var.vpc_2_cidr_private}", "${var.vpc_3_cidr_private}"]
  }


  vpc_id = aws_vpc.IS_VPC1.id

  tags = {
    Name        = "Nginx"
    Description = "Security group for backends"
  }
}


resource "aws_instance" "web-1" {
  ami                         = "ami-0c46192d65be87c42"
  availability_zone           = "us-east-1b"
  instance_type               = "t2.micro"
  key_name                    = "lastkeys"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = aws_subnet.aws-1-subnet-private.id
  source_dest_check           = false
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = file("nginx_add.sh")
  iam_instance_profile        = aws_iam_instance_profile.s3roacess_iam.name
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = "Nginx 1"
    Description = "Backend server"
    owner       = "Konstantin"
    project     = "devops school"
    enviroment  = "learning"

  }
}

resource "aws_instance" "web-2" {
  ami                         = "ami-0c46192d65be87c42"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.micro"
  key_name                    = "lastkeys"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = aws_subnet.aws-2-subnet-private.id
  source_dest_check           = false
  associate_public_ip_address = false
  monitoring                  = true
  user_data                   = file("nginx_add.sh")
  iam_instance_profile        = aws_iam_instance_profile.s3roacess_iam.name
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = "Nginx 2"
    Description = "Backend server"
    owner       = "Konstantin"
    project     = "devops school"
  }
}


output "web_ips" {
  value = ["${aws_instance.web-1.*.private_ip}", "${aws_instance.web-2.*.private_ip}"]
}
