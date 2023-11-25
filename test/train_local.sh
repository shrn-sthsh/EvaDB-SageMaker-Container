#!/bin/sh

# This script runs a Docker container using the specified image for training a machine learning model.

# Extract the image name from the command-line argument
image=$1

# Create necessary directories for model and output
mkdir -p test/model
mkdir -p test/output

# Remove existing files in model and output directories
rm test/model/*
rm test/output/*

# Run a Docker container with the following options:
# -v: Mount the 'test' directory from the current host into '/app/learning' inside the container
# --rm: Remove the container after it exits
# ${image}: Use the specified Docker image
# train: Run the 'train' command inside the container
docker run -v $(pwd)/test:/app/learning --rm ${image} train
