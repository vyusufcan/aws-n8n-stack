data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

locals {
  name_prefix          = "${var.project_name}-${var.environment}"
  ssh_ingress_cidr     = "${trimspace(data.http.my_ip.response_body)}/32"
  kubeconfig_parameter = "/${local.name_prefix}/k3s/kubeconfig"
  k3s_ready_parameter  = "/${local.name_prefix}/k3s/private-ip"
}

resource "aws_security_group" "k3s" {
  name        = "${local.name_prefix}-k3s-sg"
  description = "Allow your IP to SSH and the VPC to reach the k3s API"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from current public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.ssh_ingress_cidr]
  }

  ingress {
    description = "k3s API from within the VPC"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-k3s-sg"
  }
}

resource "aws_iam_role" "ec2" {
  name = "${local.name_prefix}-k3s-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "kubeconfig_parameter" {
  name = "${local.name_prefix}-k3s-kubeconfig"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:PutParameter",
          "ssm:GetParameter"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:*:parameter${local.kubeconfig_parameter}",
          "arn:aws:ssm:${var.aws_region}:*:parameter${local.k3s_ready_parameter}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-k3s-ec2-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_instance" "k3s" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.k3s_instance_type
  subnet_id                   = data.aws_subnet.selected.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.k3s.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  key_name                    = var.key_pair_name
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    k3s_kubeconfig_parameter = local.kubeconfig_parameter
    k3s_ready_parameter      = local.k3s_ready_parameter
    rbac_yaml_content        = file("${path.module}/RBAC.yaml")
  })

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name = "${local.name_prefix}-k3s"
  }
}
