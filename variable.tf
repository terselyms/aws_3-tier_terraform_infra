variable "aws_region" {
	description = "Region for VPC"
	default = "ap-northeast-2"
}

variable "vpc_cidr" {
	description = "CIDR for JOINC"
	default = "10.100.0.0/16"
}

variable "availability_zone" {
	description = "Seoul region availability zone"
	type = "list"
	default = ["ap-northeast-2a", "ap-northeast-2c"]
}


variable "ami" {
	description = "Amazon Linux AMI"
	default = "ami-09282971cf2faa4c9"
}
