#Create VPC
resource "aws_vpc" "TF-Project-VPC" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "TF-Project-VPC"
  }
  
}

#Creating 4 Subnets
resource "aws_subnet" "TF-Project-Public-Subnet-1" {
    vpc_id = aws_vpc.TF-Project-VPC.id
    cidr_block = "10.10.1.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = "true"

    tags = {
      "Name" = "TF-Project-Public-Subnet-1"
    }
  
}

resource "aws_subnet" "TF-Project-Public-Subnet-2" {
    vpc_id = aws_vpc.TF-Project-VPC.id
    cidr_block = "10.10.2.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = "true"

    tags = {
      "Name" = "TF-Project-Public-Subnet-2"
    }
  
}

resource "aws_subnet" "TF-Project-Private-Subnet-3" {
    vpc_id = aws_vpc.TF-Project-VPC.id
    cidr_block = "10.10.3.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = "false"

    tags = {
      "Name" = "TF-Project-Private-Subnet-3"
    }
  
}

resource "aws_subnet" "TF-Project-Private-Subnet-4" {
    vpc_id = aws_vpc.TF-Project-VPC.id
    cidr_block = "10.10.4.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = "false"

    tags = {
      "Name" = "TF-Project-Private-Subnet-4"
    }
  
}

#Security Group
resource "aws_security_group" "allow_80" {
    name = "allow_port-80"
    description = "Allow http inbound traffic"
    vpc_id = aws_vpc.TF-Project-VPC.id

    
    ingress {
    description = "http traffic"
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 80
      ipv6_cidr_blocks = ["::/0"]
      protocol = "tcp"
      to_port = 80
    }

    egress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        ipv6_cidr_blocks = ["::/0"]
        protocol = "tcp"
        to_port = 65535
    }

    tags = {
      Name = "allow_http"
    }
  
}

resource "aws_security_group" "allow_22" {
    name = "allow_port-22"
    description = "Allow http inbound traffic"
    vpc_id = aws_vpc.TF-Project-VPC.id

    
    ingress {
      description = "ssh traffic"
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 22
      ipv6_cidr_blocks = ["::/0"]
      protocol = "tcp"
      to_port = 22
    }

    egress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 0
        ipv6_cidr_blocks = ["::/0"]
        protocol = "tcp"
        to_port = 65535
    }

    tags = {
      Name = "allow_ssh"
    }
  
}

#Creating Internet Gateway
resource "aws_internet_gateway" "TF-Project-IG" {
    vpc_id = aws_vpc.TF-Project-VPC.id

    tags = {
      Name = "TF-Project-IG"
    }
  
}

# Creating Route Table-1 for Internet Gateway
resource "aws_route_table" "TF-Project-public-RT" {
    
    vpc_id = aws_vpc.TF-Project-VPC.id

    route {

      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.TF-Project-IG.id
    } 

    tags = {
      Name = "TF-Project-public-RT"
    }
  
}

# Associating the Route Table to Public Subnets
resource "aws_route_table_association" "TF-Project-Route_table_association-Subnet-1" {
  subnet_id = aws_subnet.TF-Project-Public-Subnet-1.id
  route_table_id = aws_route_table.TF-Project-public-RT.id

}

resource "aws_route_table_association" "TF-Project-Route_table_association-subnet-2" {
  subnet_id = aws_subnet.TF-Project-Public-Subnet-2.id
  route_table_id = aws_route_table.TF-Project-public-RT.id

}

#Creating NAT GW
resource "aws_nat_gateway" "TF-Project-NAT-GW-1" {
  allocation_id = aws_eip.TF-Project-eip-1.id

  #Associating it in the public subnet
  subnet_id = aws_subnet.TF-Project-Public-Subnet-1.id

  tags = {
    Name = "TF-Project-NAT-GW-1"
  }
  
}

resource "aws_nat_gateway" "TF-Project-NAT-GW-2" {
  allocation_id = aws_eip.TF-Project-eip-2.id

  #Associating it in the public subnet
  subnet_id = aws_subnet.TF-Project-Public-Subnet-2.id

  tags = {
    Name = "TF-Project-NAT-GW-2"
  }
  
}

#Creating an Elastic IP for the NAT Gateway
resource "aws_eip" "TF-Project-eip-1" {
  vpc = true
  
}

resource "aws_eip" "TF-Project-eip-2" {
  vpc = true
  
}

#Creating a Route Table for the NAT Gateway
resource "aws_route_table" "TF-Project-NAT-GW-RT-1" {
    
    vpc_id = aws_vpc.TF-Project-VPC.id

    route {

      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.TF-Project-NAT-GW-1.id
    } 

    tags = {
      Name = "TF-Project-NAT-GW-RT-1"
    }
  
}

resource "aws_route_table" "TF-Project-NAT-GW-RT-2" {
    
    vpc_id = aws_vpc.TF-Project-VPC.id

    route {

      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.TF-Project-NAT-GW-2.id
    } 

    tags = {
      Name = "TF-Project-NAT-GW-RT-2"
    }
  
}

#Create route table association between private subnet1 & NAT GW1
resource "aws_route_table_association" "Tf-Project-NAT-GW-RT1-Association" {
  route_table_id = aws_route_table.TF-Project-NAT-GW-RT-1.id
  subnet_id      = aws_subnet.TF-Project-Private-Subnet-3.id
}

#Create route table association between private subnet2 & NAT GW2
resource "aws_route_table_association" "Tf-Project-NAT-GW-RT2-Association" {
  route_table_id = aws_route_table.TF-Project-NAT-GW-RT-2.id
  subnet_id      = aws_subnet.TF-Project-Private-Subnet-4.id
}


