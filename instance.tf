provider "aws" {
  region     = "us-east-2"
}

resource "aws_key_pair" "auth" {
    key_name = "Default SSH"
    public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "instance" {
  name = "Allow SSH, web traffic, and outgoing"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
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
  provisioner "remote-exec" {
    inline = [
      "sudo yum -y update",
      "sudo yum -y install aspell aspell-en httpd24 mysql mysql-server php56 php56-cli php56-gd php56-intl php56-mbstring php56-mysqlnd php56-opcache php56-pdo php56-soap php56-xml php56-xmlrpc php56-pspell",
      "sudo /sbin/chkconfig httpd on",
      "sudo /sbin/chkconfig mysqld on",
      "sudo /sbin/service httpd start",
#      "sudo /sbin/service mysqld start",
      "sudo echo 'THIS BE MOODLE' >> /var/www/html/moodle.html",
    ]
  }
}

output "ip" {
  value = "${aws_instance.instance.public_ip}"
}
