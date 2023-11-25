#!/bin/sh

# This script runs a Docker container using the specified image for serving a machine learning model.

# Extract the image name from the command-line argument
image=$1

# Run a Docker container with the following options:
# -v: Mount the 'test_dir' directory from the current host into '/opt/ml' inside the container
# -p: Map port 8080 from the host to port 8080 in the container
# --rm: Remove the container after it exits
# ${image}: Use the specified Docker image
# serve: Run the 'serve' command inside the container
docker run -v $(pwd)/test_dir:/opt/ml -p 8080:8080 --rm ${image} serve
