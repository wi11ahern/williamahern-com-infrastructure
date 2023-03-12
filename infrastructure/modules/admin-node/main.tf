resource "aws_iam_role" "admin_node_role" {
  name = "${var.project_name}-Admin-Node"

  inline_policy {
    name = "AdminAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "*"
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS     = "arn:aws:iam::927822646792:root"
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "admin_node_instance_profile" {
  name = "${var.project_name}-Admin-Node-Profile"
  role = aws_iam_role.admin_node_role.name
}

resource "aws_security_group" "admin_node_sg" {
  name   = "${var.project_name}-Admin-Node-SG"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All ICMP - IPv4"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.common_tags
}

resource "aws_network_interface" "admin_node_nit" {
  subnet_id       = var.public_subnet_id
  security_groups = [aws_security_group.admin_node_sg.id]

  tags = local.common_tags
}

resource "aws_eip" "admin_node_eip" {
  network_interface = aws_network_interface.admin_node_nit.id

  tags = local.common_tags
}

resource "tls_private_key" "admin_node_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "admin_node_key_pair" {
  key_name   = "${var.project_name}-admin-node"
  public_key = tls_private_key.admin_node_ssh_key.public_key_openssh

  tags = local.common_tags
}

resource "aws_instance" "admin_node" {
  ami                  = data.aws_ami.amazon_linux_ami.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.admin_node_instance_profile.name
  key_name             = aws_key_pair.admin_node_key_pair.key_name
  user_data            = data.template_file.user_data_template.rendered

  network_interface {
    network_interface_id = aws_network_interface.admin_node_nit.id
    device_index         = 0
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-Admin-Node"
  })
}