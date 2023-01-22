#Creating 4 instances
resource "aws_instance" "TF-Project-instance-1" {
    ami = "ami-0384edf28491e2ae6"
    instance_type = "t2.micro"
    key_name = "Ansible-Demo-Key"
    subnet_id = aws_subnet.TF-Project-Public-Subnet-1.id
    vpc_security_group_ids = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]
    user_data = "${filebase64("user_data.sh")}"

    tags = {
      "Name" = "TF-Project-instance-1"
    }
  
}

resource "aws_instance" "TF-Project-instance-2" {
    ami = "ami-0384edf28491e2ae6"
    instance_type = "t2.micro"
    key_name = "Ansible-Demo-Key"
    subnet_id = aws_subnet.TF-Project-Public-Subnet-2.id
    vpc_security_group_ids = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]
    user_data = "${filebase64("user_data.sh")}"

    tags = {
      "Name" = "TF-Project-instance-2"
    }
  
}

resource "aws_instance" "TF-Project-instance-3" {
    ami = "ami-0384edf28491e2ae6"
    instance_type = "t2.micro"
    key_name = "Ansible-Demo-Key"
    subnet_id = aws_subnet.TF-Project-Private-Subnet-3.id
    vpc_security_group_ids = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]

    tags = {
      "Name" = "TF-Project-instance-3"
    }
  
}

resource "aws_instance" "TF-Project-instance-4" {
    ami = "ami-0384edf28491e2ae6"
    instance_type = "t2.micro"
    key_name = "Ansible-Demo-Key"
    subnet_id = aws_subnet.TF-Project-Private-Subnet-4.id
    vpc_security_group_ids = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]

    tags = {
      "Name" = "TF-Project-instance-4"
    }
  
}

#Create AWS Launch Template
resource "aws_launch_template" "TF-Project-Launch-Template" {
  name_prefix = "TF-Project-Launch-Template"
  image_id = "ami-0cca134ec43cf708f"
  instance_type = "t2.micro"
  key_name = "Ansible-Demo-Key"
  vpc_security_group_ids = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]
  user_data = "${filebase64("user_data.sh")}"
   tags = {
     Environment = "production"
     Owner = "Sandhya"
   }

}

#Create ASG Target Group
resource "aws_lb_target_group" "TF-Project-aws-lb-target-group" {
  name = "TF-Project-aws-lb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.TF-Project-VPC.id


}



#Create Auto Scaling Group
resource "aws_autoscaling_group" "TF-Project-ASG" {
  desired_capacity = 3
  max_size = 5
  min_size = 3
  vpc_zone_identifier = [aws_subnet.TF-Project-Private-Subnet-3.id,aws_subnet.TF-Project-Private-Subnet-4.id]
  

  launch_template {
    id = aws_launch_template.TF-Project-Launch-Template.id
    version = "$Latest"
  }

}

#Create Application Load Balancer
resource "aws_lb" "TF-Project-LB" {
  name = "TF-Project-LB"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow_80.id,aws_security_group.allow_22.id]
  subnets = [aws_subnet.TF-Project-Public-Subnet-1.id,aws_subnet.TF-Project-Public-Subnet-2.id]
  
  
}

#Create ALB Listener
resource "aws_lb_listener" "TF-Project-ALB-Listener" {
  load_balancer_arn = aws_lb.TF-Project-LB.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.TF-Project-aws-lb-target-group.arn

  }
  
}

#Autoscaling Group Attachment
resource "aws_autoscaling_attachment" "TF-Project-autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.TF-Project-ASG.id
  alb_target_group_arn = aws_lb_target_group.TF-Project-aws-lb-target-group.arn
  
}


