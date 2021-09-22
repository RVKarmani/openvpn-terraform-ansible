variable "OPEN_VPN_PORT" {}
variable "EC2_AMI" {}
variable "INSTANCE_TYPE" {}
variable "VPN_SSH_PUBLIC_KEY" {}
variable "VPN_SSH_PRIVATE_KEY" {}
variable "OPEN_VPN_SG" {}

# DEFAULT VPC
data "aws_vpc" "default" {
  default = true
} 

# SG
resource "aws_security_group" "openvpn_sg" {
    name = var.OPEN_VPN_SG
    vpc_id = data.aws_vpc.default.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = var.OPEN_VPN_PORT
        to_port = var.OPEN_VPN_PORT
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [data.aws_vpc.default.cidr_block]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key pair

resource "aws_key_pair" "openvpn_auth" {
  key_name   = "openvpn-key"
  public_key = file(var.VPN_SSH_PUBLIC_KEY)
}

# EC2 instance
resource "aws_instance" "openvpn_instance" {
    ami = var.EC2_AMI
    key_name = aws_key_pair.openvpn_auth.id
    instance_type = var.INSTANCE_TYPE
    security_groups = [aws_security_group.openvpn_sg.id]
    associate_public_ip_address = true
    tags = {
        Name = "openvpn_instance"
    }
}

# GENERATE ANSIBLE INVENTORY
resource "local_file" "ansible_inventory" {
  content = <<EOF
[openvpn_instance]
${aws_instance.openvpn_instance.public_ip}

[openvpn_public:vars]
aws_region=${data.aws_region.current.name}
ansible_ssh_private_key_file=${var.VPN_SSH_PRIVATE_KEY}
ansible_python_interpreter=/usr/bin/python3
public_ip=${aws_instance.openvpn_instance.public_ip}
ovpn_port=${var.OPEN_VPN_PORT}
EOF

  filename = "${path.module}/../ansible/hosts"
}