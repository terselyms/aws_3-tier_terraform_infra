resource "aws_lb" "web-alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = ["${aws_security_group.web-alb.id}"]
  subnet_mapping {
    subnet_id     = "${aws_subnet.public[0].id}"
  }
  subnet_mapping {
    subnet_id     = "${aws_subnet.public[1].id}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.web-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tg80.arn}"
  }
}

resource "aws_lb_target_group" "tg80" {
  name     = "tg80"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.minsik-vpc.id}"
}

resource "aws_lb_target_group_attachment" "tg_web-1" {
  target_group_arn = "${aws_lb_target_group.tg80.arn}"
  target_id        = "${aws_instance.web-1.id}"
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_web-2" {
  target_group_arn = "${aws_lb_target_group.tg80.arn}"
  target_id        = "${aws_instance.web-2.id}"
  port             = 80
}

resource "aws_lb" "was-alb" {
  name               = "was-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = ["${aws_security_group.was-alb.id}"]
  subnet_mapping {
    subnet_id     = "${aws_subnet.private[0].id}"
  }
  subnet_mapping {
    subnet_id     = "${aws_subnet.private[1].id}"
  }
}

resource "aws_lb_listener" "tomcat" {
  load_balancer_arn = "${aws_lb.was-alb.arn}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.tg8080.arn}"
  }
}

resource "aws_lb_target_group" "tg8080" {
  name     = "tg8080"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.minsik-vpc.id}"
}

resource "aws_lb_target_group_attachment" "tg_was-1" {
  target_group_arn = "${aws_lb_target_group.tg8080.arn}"
  target_id        = "${aws_instance.was-1.id}"
  port             = 8080
}

resource "aws_lb_target_group_attachment" "tg_was-2" {
  target_group_arn = "${aws_lb_target_group.tg8080.arn}"
  target_id        = "${aws_instance.was-2.id}"
  port             = 8080
}

