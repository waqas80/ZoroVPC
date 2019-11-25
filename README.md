VPC(Virtual Private Cloud) is an isolated group of infrastructure resources in a public cloud environment. It is a virtual network same as on premises, but on public cloud and the benefit of VPC is scalable infrastructure. In this example I will create a VPC and add two public subnets in two availability zones. Then I will add EC2 instances in each availability zone and add application load balancer. On top I will add internet gateway to allow traffic from internet.  I named my VPC Zoro, you can name any.

I created the VPC. CIDR (Classless Inter Domain Routing) block IP address rang I set to ‘10.0.0.0/16’. Instance tenancy I set to default. With default option the VPC will be created on shared resources. If you set the ‘instance_tenancy’ value to ‘dedicated’, AWS will reserve dedicated resources for the VPC. For enterprise projects its a good idea. But for small projects or for demo I would suggest to set instance_tenancy to default so your resource will remain in free tier or it cost you minimal. In the next step I created two subnets in two availability zones. And keep them under the VPC by using the VPC Id ‘${aws_vpc.zorovpc.id}’. Then add the two EC2 T2 micro instances in two subnets. User data file is created and each instance will get update and installed Apache. An Index.html page gets created on each instance which will display the IP address of each instance.

Project Files

	 userdata.sh: This file contains the user data. It will run an update on the instance. Then user data will install Apache server and create an index.html page. The index page will display the IP address of the server.
	 
     variables.tf: This file contains the variables values
     
     zorovpc.tf: This file contains the complete code of creating VPC, SubNets, Load Balancer, EC2 instances, security groups and routing table.
     
You can find more detail about this code on http://geeksstack.com/create-aws-vpc-public-subnet-using-terraform/
