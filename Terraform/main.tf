provider "aws" {
  access_key = 
  secret_key = ""
  region = ""
}


resource "aws_instance" "jenkins" {
  ami = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.open_ports.id]
  key_name = "TF_key"
}

resource "aws_instance" "tomcat" {
  ami = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.open_ports.id]
  key_name = "TF_key"
}


resource "aws_security_group" "open_ports" {
  name        = "open_ports"
  description = "open ports"

  ingress {
    description = "Tomcat/Jenkins"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WebHook"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "open_ports"
  }
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}


output "instance_public_ip_jenkins" {
  description = "Public IP address of the jenkins instance"
  value       = aws_instance.jenkins.public_ip
}

output "instance_public_ip_tomcat" {
  description = "Public IP address of the tomcat instance"
  value       = aws_instance.tomcat.public_ip
}