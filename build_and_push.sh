#!/usr/bin/env bash

# This script builds a Docker image and pushes it to 
# Amazon ECR for use with SageMaker.

# Check if an image name is provided as an argument
image=$1
if [ -z "$image" ]; then
    echo "Usage: $0 <image-name>"
    exit 1
fi

# Make the train and serve scripts executable
chmod +x evadb_instance/train
chmod +x evadb_instance/serve

# Get the AWS account number associated with the current IAM credentials
account=$(aws2 sts get-caller-identity --query Account --output text)
if [ $? -ne 0 ]; then
    exit 255
fi

# Get the AWS region defined in the current configuration (default to us-west-2 if none defined)
region=$(aws2 configure get region)
region=${region:-us-east-1}

# Form the full image name including the ECR repository information
fullname="${account}.dkr.ecr.${region}.amazonaws.com/${image}:latest"

# If the repository doesn't exist in ECR, create it
aws2 ecr describe-repositories --repository-names "${image}" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    aws2 ecr create-repository --repository-name "${image}" > /dev/null
fi

# Authenticate Docker to the ECR registry
$(aws2 ecr get-login --region ${region} --no-include-email)

# Build the Docker image locally, tag it, and push it to ECR
docker build -t ${image} .
docker tag ${image} ${fullname}
docker push ${fullname}
