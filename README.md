# OpenClaw on AWS — Terraform

A minimal Terraform project that deploys [OpenClaw](https://docs.openclaw.ai/) on a single AWS EC2 instance using Docker.

## What gets created

| Resource | Details |
|----------|---------|
| EC2 instance | Amazon Linux 2023, t3.medium (4 GB RAM), 20 GB gp3 root volume |
| Security group | Allows SSH (22) and OpenClaw gateway (18789) |
| Docker container | `ghcr.io/openclaw/openclaw:latest` running the gateway |

Everything runs in your account's **default VPC**. No databases or extra services are required — OpenClaw stores its config and workspace on the instance's filesystem.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- AWS CLI configured with credentials (`aws configure`)
- An existing [EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) for SSH access
- An API key from your LLM provider (Anthropic, OpenAI, Google, etc.)

## Quick start

```bash
# 1. Clone and enter the repo
git clone <this-repo-url>
cd openclaw-aws-terraform

# 2. Create your variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Deploy
terraform init
terraform plan
terraform apply
```

After `apply` completes, Terraform prints:

- **gateway_url** — open this in your browser to access the OpenClaw dashboard
- **ssh_command** — use this to SSH into the instance

> **Note:** It may take 1–2 minutes after instance launch for Docker to pull the image and start the container.

## Connecting chat channels

Once the gateway is running, SSH into the instance and run:

```bash
docker exec -it openclaw-gateway openclaw channels login
```

Follow the prompts to connect WhatsApp, Telegram, Discord, or other channels. See the [OpenClaw channel docs](https://docs.openclaw.ai/) for details.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | AWS region |
| `instance_type` | `t3.medium` | EC2 instance type (t3.medium recommended) |
| `key_name` | — | Name of your EC2 key pair |
| `llm_env_vars` | — | Map of LLM provider env vars (e.g. `{ ANTHROPIC_API_KEY = "..." }`) |
| `allowed_ssh_cidrs` | `["0.0.0.0/0"]` | CIDRs allowed to SSH |
| `allowed_gateway_cidrs` | `["0.0.0.0/0"]` | CIDRs allowed to reach the gateway |
| `openclaw_image` | `ghcr.io/openclaw/openclaw:latest` | Docker image to use |

## Tear down

```bash
terraform destroy
```

## License

MIT
