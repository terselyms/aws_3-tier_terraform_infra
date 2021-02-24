resource "aws_security_group" "bastion" {
  vpc_id = "${aws_vpc.minsik-vpc.id}"

  name = "bastion"
  description = "Allow incoming SSH access"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["1.242.31.207/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion"
  }
}

resource "aws_security_group" "web-alb" {
  vpc_id = "${aws_vpc.minsik-vpc.id}"

  name = "web-alb"
  description = "Allow incoming HTTP"
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web-alb"
  }
}

resource "aws_security_group" "web" {
  vpc_id = "${aws_vpc.minsik-vpc.id}"

  name = "web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.web-alb.id}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web"
  }
}

resource "aws_security_group" "was-alb" {
  vpc_id = "${aws_vpc.minsik-vpc.id}"

  name = "was-alb"
  description = "Allow incoming tomcat"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = ["${aws_security_group.web.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "was-alb"
  }
}

resource "aws_security_group" "was" {
  vpc_id = "${aws_vpc.minsik-vpc.id}"

  name = "was"
  description = "Allow incoming tomcat connections & SSH access"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = ["${aws_security_group.was-alb.id}"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "was"
  }
}


