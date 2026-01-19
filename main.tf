provider "aws" {
  region = "us-south-ap1"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

resource "aws_vpc" "snehalvpc" {
  region = "us-south-ap1"
  cidr_block = var.cidr

}

resource "aws_key_pair" "keypair" {
   key_name = "snehal-keypair"
   public_key = "C:\Users\user/.ssh/id_rsa.pub"
}

resource "aws_subnet" "snehalsubnet" {
    vpc_id = aws_vpc.snehalvpc
    availability_zone = "us-south-ap1"
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "snehaligw" {
  vpc_id = aws_vpc.snehalvpc

}

resource "aws_route_table" "snehalroutetable" {
  vpc_id = aws_vpc.snehalvpc
    
     route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.snehaligw
     }
    }   

resource "aws_route_table_association" "rta" {
    subnet_id = aws_subnet.snehalsubnet
    route_table_id = aws_key_pair.keypair
}

resource "aws_security_group" "snehalsg" {

    name = "snehalsg"
    vpc_id = aws_vpc.snehalvpc

        ingress {
          description= "allows access to domain"
          from_port= 80
          to_port=80
          protocol="tcp"
          cidr_blocks = "0.0.0.0/0"
        }

        ingress {
          description = "ssh allow"
          from_port = 22
          to_port = 22
          protocol = "tcp"
          cidr_blocks = "0.0.0.0/0"
        }

        egress {
          description = "allow everything"
          from_port = 0
          to_port = 0
          protocol = "-1"
          cidr_blocks = "0.0.0.0/0"
        }
}

resource "aws_instance" "snehal-server" {
  ami = "ami-02b8269d5e85954ef"
  instance_type = "t3.micro"
  key_name = aws_key_pair.keypair.key_name
  vpc_security_group_ids = aws_security_group.snehalsg.id
  subnet_id = aws_subnet.snehalsubnet.id


  connection {
     type = "ssh"
    user = "ec2-user"
    private_key = file("C:\Users\user/.ssh/id_rsa")
    host = self.public_ip
  }

  provisioner "file" {
    source = "C:\Users\user\Music\app.py"
    destination = "/home/ec2-user/app.py"
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",
    ]
  }
}

