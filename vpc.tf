resource "aws_vpc" "fridayvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "fridayvpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.fridayvpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    "Name" = "Public Subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.fridayvpc.id
  tags = {
    "Name" = "IGW"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.fridayvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "ssh_http_security" {
  name = "allow_http_ssh"
  description = "Allow HTTP and SSH"
  vpc_id = aws_vpc.fridayvpc.id

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "SSH"
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "HTTP"
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    ipv6_cidr_blocks = ["::/0"]
    protocol = "-1"
    to_port = 0
  }
  tags = {
    "Name" = "allow_http_ssh"
  } 
}

resource "aws_instance" "fridayec2" {
  ami = "ami-08e2d37b6a0129927"
  instance_type = "t3.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [ aws_security_group.ssh_http_security.id ]
  key_name = "vockey"
  user_data = file("userdata.sh")
  tags = {
    "Name" = "fridayec2"
  }
}