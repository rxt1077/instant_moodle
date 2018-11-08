provider "aws" {
  region     = "us-east-2"
}

resource "aws_key_pair" "auth" {
    key_name = "Default SSH"
    public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "instance" {
  name = "Allow SSH and all outgoing"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance" {
  ami           = "ami-0b59bfac6be064b78"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  key_name = "Default SSH"
  connection {
        type = "ssh"
        user = "ec2-user"
        private_key = "${file("~/.ssh/id_rsa")}"
  }
}

output "ip" {
  value = "${aws_instance.instance.public_ip}"
}
