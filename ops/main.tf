provider "aws" {
    region = "eu-north-1"
  }

  resource "aws_security_group" "allow_http_ssh" {
    name        = "allow_http_ssh"
    description = "Allow HTTP and SSH"

    ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      description = "Allow all outbound"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  resource "aws_instance" "my_instance" {
    ami                    = "ami-0c1ac8a41498c1a9c"
    instance_type          = "t3.micro"
    key_name               = "it_infra_labs_key"
    vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]

    user_data = <<-EOF
                #!/bin/bash
                exec > /var/log/setup.log 2>&1
                set -e
                set -x

                apt update -y

                apt install -y docker.io
                systemctl start docker
                systemctl enable docker

                docker run -d --name ci-cd-web-app -p 80:80 yeshanov/myeshanov_ci-cd-lab
                docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower ci-cd-web-app --interval 30
                EOF

    tags = {
      Name = "CI/CD Labs"
    }
  }
