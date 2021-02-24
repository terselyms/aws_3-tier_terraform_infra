data "template_file" "user_data_1" {
  template = file("./install_apache2.sh")
}

data "template_file" "user_data_2" {
  template = file("./install_tomcat.sh")
}

resource "aws_vpc" "minsik-vpc" {
	cidr_block = "${var.vpc_cidr}"
	enable_dns_hostnames = true

	tags = {
		Name = "minsik-vpc"
	}
}

resource "aws_subnet" "public" {
	count = 2
	vpc_id = "${aws_vpc.minsik-vpc.id}"
	cidr_block = "${cidrsubnet(var.vpc_cidr, 8, count.index)}"
	availability_zone = "${element(var.availability_zone, count.index)}"
	tags = {
		Name = "Public Subnet - ${element(var.availability_zone, count.index)}"
	}
}

resource "aws_subnet" "private" {
	count = 6
	vpc_id = "${aws_vpc.minsik-vpc.id}"
	cidr_block = "${cidrsubnet(var.vpc_cidr, 8, count.index+2)}"
	availability_zone = "${element(var.availability_zone, count.index)}"
	tags = {
		Name = "Private Subnet - ${element(var.availability_zone, count.index)}"
	}
}



/*
Internet gateway
*/
resource "aws_internet_gateway" "igw" {
	vpc_id = "${aws_vpc.minsik-vpc.id}"

	tags = {
		Name = "VPC IGW"
	}
}

/*
NAT Gateway Configuration
*/
resource "aws_eip" "nat_eip" {
	vpc = true
	depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_nat_gateway" "nat" {
	allocation_id = "${aws_eip.nat_eip.id}"
	subnet_id = "${element(aws_subnet.public.*.id, 0)}"
	depends_on = ["aws_internet_gateway.igw"]
}


/*
Public Route Configuration
*/
resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.minsik-vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.igw.id}"
	}

	tags = {
		Name = "Public Subnet Route Table"
	}
}

/*
Private Subnet Configuration
*/
resource "aws_route_table" "private" {
	vpc_id = "${aws_vpc.minsik-vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_nat_gateway.nat.id}"
	}

	tags = {
		Name = "Private Subnet Route Table"
	}
}

resource "aws_route_table_association" "public" {
	count = 2
	subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
	route_table_id = "${aws_route_table.public.id}"
}


resource "aws_route_table_association" "private" {
	count = 6
	subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
	route_table_id = "${aws_route_table.private.id}"
}

resource "aws_key_pair" "web_admin" {
  key_name = "web_admin"
  public_key = file("~/.ssh/web_admin.pub")
}

resource "aws_instance" "bastion" {
  ami = "ami-09282971cf2faa4c9"
  instance_type = "t2.micro"
  key_name = aws_key_pair.web_admin.key_name
  subnet_id = "${aws_subnet.public[0].id}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  associate_public_ip_address = true
  source_dest_check = false

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "web-1" {
  ami = "ami-09282971cf2faa4c9"
  instance_type = "t2.micro"
  key_name = aws_key_pair.web_admin.key_name
  subnet_id = "${aws_subnet.private[0].id}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  associate_public_ip_address = false
  source_dest_check = false
  user_data = data.template_file.user_data_1.rendered

  tags = {
    Name = "webserver-1"
  }
}
resource "aws_instance" "web-2" {
  ami = "ami-09282971cf2faa4c9"
  instance_type = "t2.micro"
  key_name = aws_key_pair.web_admin.key_name
  subnet_id = "${aws_subnet.private[1].id}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  associate_public_ip_address = false
  source_dest_check = false
  user_data = data.template_file.user_data_1.rendered

  tags = {
    Name = "webserver-2"
  }
}


resource "aws_instance" "was-1" {
  ami = "ami-09282971cf2faa4c9"
  instance_type = "t2.micro"
  key_name = aws_key_pair.web_admin.key_name
  subnet_id = "${aws_subnet.private[2].id}"
  vpc_security_group_ids = ["${aws_security_group.was.id}"]
  user_data = data.template_file.user_data_2.rendered
                                                                 
  tags =  {
    Name = "applicationserver-1"
  }
}
resource "aws_instance" "was-2" {
  ami = "ami-09282971cf2faa4c9"
  instance_type = "t2.micro"
  key_name = aws_key_pair.web_admin.key_name
  subnet_id = "${aws_subnet.private[3].id}"
  vpc_security_group_ids = ["${aws_security_group.was.id}"]
  user_data = data.template_file.user_data_2.rendered

  tags =  {
    Name = "applicationserver-2"
  }
}

                          
