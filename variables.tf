variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type (t3.medium recommended)"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
}

variable "llm_env_vars" {
  description = "Environment variables for your LLM provider (e.g. ANTHROPIC_API_KEY, OPENAI_API_KEY, etc.)"
  type        = map(string)
  sensitive   = true
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_gateway_cidrs" {
  description = "CIDR blocks allowed to access the OpenClaw gateway (port 18789)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "openclaw_image" {
  description = "OpenClaw Docker image"
  type        = string
  default     = "ghcr.io/openclaw/openclaw:latest"
}
