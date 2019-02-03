#!/bin/bash
# ECS config
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"awslogs\"] >> /etc/ecs/ecs.config
# Install JQ JSON parser
yum install -y jq
# Get the current region from the instance metadata
region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
# Install the SSM agent RPM
yum install -y https://amazon-ssm-$region.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm
EOF
