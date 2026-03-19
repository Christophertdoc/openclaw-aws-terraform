# --- Data Sources ---

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- Locals ---

locals {
  # Auto-detect the agent model from whichever API key is provided.
  # First key found wins. Can be overridden via openclaw_env_vars["OPENCLAW_MODEL"].
  agent_model = lookup(var.openclaw_env_vars, "OPENCLAW_MODEL", (
    contains(keys(var.openclaw_env_vars), "ANTHROPIC_API_KEY") ? "anthropic/claude-sonnet-4-20250514" :
    contains(keys(var.openclaw_env_vars), "OPENAI_API_KEY") ? "openai/gpt-4o" :
    contains(keys(var.openclaw_env_vars), "GOOGLE_API_KEY") ? "google/gemini-2.5-pro" :
    "anthropic/claude-sonnet-4-20250514"
  ))
}

# --- Security Group ---

resource "aws_security_group" "openclaw" {
  name_prefix = "openclaw-"
  description = "Allow SSH and OpenClaw gateway access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    description = "OpenClaw Gateway"
    from_port   = 18789
    to_port     = 18789
    protocol    = "tcp"
    cidr_blocks = var.allowed_gateway_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "openclaw-sg"
  }
}

# --- EC2 Instance ---

resource "aws_instance" "openclaw" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.openclaw.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    openclaw_image         = var.openclaw_image
    openclaw_env_vars      = var.openclaw_env_vars
    agent_model            = local.agent_model
    telegram_allowed_users = var.telegram_allowed_users
  })

  tags = {
    Name = "openclaw"
  }
}
