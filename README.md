# OpenClaw on AWS — Terraform

A minimal Terraform project that deploys [OpenClaw](https://docs.openclaw.ai/) on a single AWS EC2 instance using Docker.

## What gets created

| Resource | Details |
|----------|---------|
| EC2 instance | Amazon Linux 2023, t3.medium (4 GB RAM), 30 GB gp3 root volume |
| Security group | Allows SSH (22) and OpenClaw gateway (18789) |
| Docker container | `ghcr.io/openclaw/openclaw:latest` running the gateway |

Everything runs in your account's **default VPC**. No databases or extra services are required — OpenClaw stores its config and workspace on the instance's filesystem.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- AWS CLI configured with a named profile (`aws configure --profile openclaw`)
- An EC2 key pair for SSH access (see below to create one)
- An API key from your LLM provider (Anthropic, OpenAI, Google, etc.)

## Quick start

```bash
# 1. Clone and enter the repo
git clone <this-repo-url>
cd openclaw-aws-terraform

# 2. Set your AWS profile
export AWS_PROFILE=openclaw

# 3. Create an EC2 key pair (skip if you already have one)
aws ec2 create-key-pair --key-name openclaw-key --query 'KeyMaterial' --output text > ~/.ssh/openclaw-key.pem
chmod 400 ~/.ssh/openclaw-key.pem

# 4. Create your variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your key pair name and LLM API key(s)

# 5. Deploy
terraform init
terraform plan
terraform apply
```

After `apply` completes, Terraform prints:

- **gateway_url** — open this in your browser to access the OpenClaw dashboard
- **ssh_command** — use this to SSH into the instance

> **Note:** It may take 1–2 minutes after instance launch for Docker to pull the image and start the container.

## Verify it's running

```bash
# SSH into the instance (use the ssh_command from the Terraform output)
ssh -i ~/.ssh/openclaw-key.pem ec2-user@<public-ip>

# Check the container is up
docker ps
docker logs openclaw-gateway
```

Then open `http://<public-ip>:18789` in your browser to access the OpenClaw dashboard.

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
