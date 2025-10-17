# Create/import an EC2 key from your provided public key
resource "aws_key_pair" "ctfd" {
  key_name   = "${var.project_name}-key"
  public_key = var.public_key
}

# Latest Ubuntu 22.04 LTS AMI via SSM
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -eux

    # Basic updates + Docker
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    usermod -aG docker ubuntu

    # Create persistent directories
    mkdir -p /opt/ctfd/{uploads,logs,conf}
    chown -R ubuntu:ubuntu /opt/ctfd

    # Start CTFd container
    docker pull ${var.ctfd_image}
    docker run -d --name ctfd \
      --restart unless-stopped \
      -p 0.0.0.0:8000:8000 \
      -v /opt/ctfd/uploads:/var/uploads \
      -v /opt/ctfd/logs:/var/log/CTFd \
      -e UPLOAD_FOLDER=/var/uploads \
      -e LOG_FOLDER=/var/log/CTFd \
      ${var.ctfd_image}

    # Simple ufw just in case (EC2 SG already restricts)
    apt-get install -y ufw
    ufw allow 22/tcp
    ufw allow 8000/tcp
    ufw --force enable
  EOF
}

resource "aws_instance" "ctfd" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.instance_type
  subnet_id                   = values(aws_subnet.public)[0].id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.ctfd.key_name
  associate_public_ip_address = true
  user_data                   = local.user_data

  root_block_device {
    volume_type = "gp3"
    volume_size = var.ec2_disk_gb
  }

  tags = { Name = "${var.project_name}-ec2" }
}

# Register instance with target group
resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ctfd.id
  port             = 8000
}
