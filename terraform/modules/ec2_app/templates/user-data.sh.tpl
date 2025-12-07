#!/bin/bash
set -e
# Install Docker
amazon-linux-extras install -y docker || true
service docker start || true
usermod -a -G docker ec2-user || true
# Install docker-compose (docker compose plugin)
if ! command -v docker-compose >/dev/null 2>&1; then
  curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose || true
fi

# Pull docker-compose file from S3 if provided
if [ -n "${S3_COMPOSE_BUCKET:-}" ]; then
  aws s3 cp s3://${S3_COMPOSE_BUCKET}/${S3_COMPOSE_KEY:-docker-compose.yml} /home/ec2-user/docker-compose.yml || true
fi

cd /home/ec2-user || true
if [ -f docker-compose.yml ]; then
  docker-compose up -d --remove-orphans || true
fi

# Start CloudWatch agent if config provided
if [ -n "${CLOUDWATCH_CONFIG_S3:-}" ]; then
  aws s3 cp s3://${CLOUDWATCH_CONFIG_S3} /tmp/cw-config.json || true
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/tmp/cw-config.json -s || true
fi
