data "aws_vpc" "minsik-vpc" {
  default = true
}

resource "aws_db_subnet_group" "rds-subnet" {
  name       = "rds-subnet"
  subnet_ids = [aws_subnet.private[4].id, aws_subnet.private[5].id]

  tags = {
    Name = "rds-subnet"
  }
}

resource "aws_db_option_group" "rds-option" {
  name                     = "rds-option"
  engine_name              = "${var.engine_name}"
  major_engine_version     = "${var.major_engine_version}"

  tags = {
    Name = "rds-option"
  }

  option {
    option_name  = "MARIADB_AUDIT_PLUGIN"

    option_settings {
      name  = "SERVER_AUDIT_EVENTS"
      value = "CONNECT"
    }
  }
}

resource "aws_db_parameter_group" "rds-parameter" {
  name        = "rds-parameter"
  family      = "${var.family}"

  tags = {
    Name = "rds-parameter"
  }

  parameter {
    name  = "general_log"
    value = "0"
  }

}

resource "aws_security_group" "db_instance" {
  name   = "db_instance"
  vpc_id = "${aws_vpc.minsik-vpc.id}"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.was.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "db_sg"
  }


}

resource "aws_security_group_rule" "allow_db_access" {
  type              = "ingress"
  from_port         = "${var.port}"
  to_port           = "${var.port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.db_instance.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_db_instance" "rds-server" {
  identifier              = "rds-server"
  engine                  = "${var.engine_name}"
  engine_version          = "${var.engine_version}"
  port                    = "${var.port}"
  name                    = "${var.database_name}"
  username                = "${var.username}"
  password                = "${var.password}"
  instance_class          = "db.t2.micro"
  allocated_storage       = "${var.allocated_storage}"
  skip_final_snapshot     = true
  license_model           = "${var.license_model}"
  db_subnet_group_name    = "${aws_db_subnet_group.rds-subnet.id}"
  vpc_security_group_ids  = ["${aws_security_group.db_instance.id}"]
  publicly_accessible     = false
  parameter_group_name    = "${aws_db_parameter_group.rds-parameter.id}"
  option_group_name       = "${aws_db_option_group.rds-option.id}"

  tags = {
    Name = "rds-server"
  }
}
