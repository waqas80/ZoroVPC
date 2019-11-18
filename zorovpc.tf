provider "aws" {
	access_key = "${var.aws_access_key}"
	secret_key = "${var.aws_secret_key}"
	region = "${var.region}"
}

##### VPC ######
resource "aws_vpc" "zorovpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "ZoroVPC"
    }
}

######## SubNet  #############
resource "aws_subnet" "zorosubone" {
    vpc_id = "${aws_vpc.zorovpc.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Zoro-SubNet-One"
    }
}

resource "aws_subnet" "zorosubtwo" {
    vpc_id = "${aws_vpc.zorovpc.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
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

resource "aws_route_table_association" "route-tbl-link1" {
  subnet_id = "${aws_subnet.zorosubone.id}"
  route_table_id = "${aws_route_table.main-public-rt.id}"
}

resource "aws_route_table_association" "route-tbl-link2" {
  subnet_id = "${aws_subnet.zorosubtwo.id}"
  route_table_id = "${aws_route_table.main-public-rt.id}"
}

##### ALB Security Group ######
resource "aws_security_group" "lb-sg" {
  name = "zoro-lb-sg"
  description = "Load balancer security group"
  vpc_id = "${aws_vpc.zorovpc.id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
######## ALB ############
resource "aws_lb" "zorolb" {
    name = "zoro-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = ["${aws_security_group.lb-sg.id}"]
    subnets = ["${aws_subnet.zorosubone.id}","${aws_subnet.zorosubtwo.id}"]
    
}
##### ALB Target Group
resource "aws_alb_target_group" "lb-tg" {
  name = "zoro-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_vpc.zorovpc.id}"

}
###### LB Listner #####
resource "aws_alb_listener" "lb-listner" {
  load_balancer_arn = "${aws_lb.zorolb.arn}"
  port = "80"
  protocol = "HTTP"
  default_action {
      target_group_arn = "${aws_alb_target_group.lb-tg.arn}"
      type = "forward"
  }
}


######## Security Group ######
resource "aws_security_group" "ec2_sg" {
  name = "allow_http"
  vpc_id = "${aws_vpc.zorovpc.id}"
  ingress {
      from_port = 80
      to_port = 80
      protocol = "TCP"
      security_groups = ["${aws_security_group.lb-sg.id}"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

###### EC2 #####

resource "aws_instance" "myinstance-one" {
	ami = "ami-0b69ea66ff7391e80"
	instance_type = "t2.micro"
    availability_zone = "${var.aws_zone_one}"
    subnet_id = "${aws_subnet.zorosubone.id}"
    vpc_security_group_ids = ["${aws_security_group.ec2_sg.id}"]
    user_data = "${file("userdata.sh")}"
	tags = {
		Name = "EC2one"
	}
}



resource "aws_instance" "myinstance-two" {
	ami = "ami-0b69ea66ff7391e80"
	instance_type = "t2.micro"
    availability_zone = "${var.aws_zone_two}"
    subnet_id = "${aws_subnet.zorosubtwo.id}"
    vpc_security_group_ids = ["${aws_security_group.ec2_sg.id}"]
    user_data = "${file("userdata.sh")}"
	tags = {
		Name = "EC2two"
	}
}

###### Target group attachment #####
resource "aws_alb_target_group_attachment" "alb_instance1" {
  target_group_arn = "${aws_alb_target_group.lb-tg.arn}"
  target_id = "${aws_instance.myinstance-one.id}"
  port = 80
}

resource "aws_alb_target_group_attachment" "alb_instance2" {
  target_group_arn = "${aws_alb_target_group.lb-tg.arn}"
  target_id = "${aws_instance.myinstance-two.id}"
  port = 80
}
