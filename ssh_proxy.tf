## Proxy instance

resource "aws_security_group" "ssh_proxy" {
  name        = "vpc_proxy"
  description = "Proxy scurity policies."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.IS_VPC1.id

  tags = {
    Name        = "SshProxy"
    Description = "Security group for SSH proxy to VPC"
  }
}

resource "aws_instance" "ssh_proxy" {
  #    ami = "${data.aws_ami.ssh_proxy_ami.image_id}"
  ami                         = "ami-0c46192d65be87c42"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.micro"
  key_name                    = "lastkeys"
  vpc_security_group_ids      = ["${aws_security_group.ssh_proxy.id}"]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.aws-1-subnet-public.id
  user_data                   = file("ssh_add.sh")
  root_block_device {
    volume_size = 10
  }
  tags = {
    Name        = "SSH-Proxy"
    Description = "SSH Proxy to VPCs"
    owner       = "I.M. gostik"
    project     = "devops school"
    enviroment  = "learning"
  }
}

#resource "aws_eip" "eip_proxy" {
#  instance = "${aws_instance.ssh_proxy.id}"
#}

output "ssh_proxy_ip" {
  value = aws_instance.ssh_proxy.public_ip
}
