provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.region}"
}

resource "aws_vpc" "zorovpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "ZoroVPC"
    }
}

######## SubNetOne #############
resource "aws_subnet" "zorosubone" {
    vpc_id = "${aws_vpc.zorovpc.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "Zoro-SubNet-One"
    }
}

resource "aws_subnet" "zorosubtwo" {
    vpc_id = "${aws_vpc.zorovpc.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "Zoro-SubNet-Two"
    }
}

##### Internet Gateway ######

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.zorovpc.id}"
    
    tags = {
        Name = "Zoro-IGW"
    }
}

############# NAT #############

resource "aws_eip" "nat" {
  
}

resource "aws_nat_gateway" "natgateway" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.zorosubone.id}"

  tags = {
      Name = "Zoro-Nat-Getway"
  }
}

############## Route Table ##############
resource "aws_route_table" "main-public-rt" {
    vpc_id = "${aws_vpc.zorovpc.id}"
    route{
        cidr_block="0.0.0.0/0"
        gateway_id="${aws_internet_gateway.igw.id}"
    }

    tags = {
        Name="zoro-public-rt"
    }
}

resource "aws_route_table" "main-private-rt"{
    vpc_id = "${aws_vpc.zorovpc.id}"
    route{
        cidr_block="0.0.0.0/0"
        gateway_id="${aws_nat_gateway.natgateway.id}"
    }

    tags = {
        Name = "zoro-private-rt"
    }
}
