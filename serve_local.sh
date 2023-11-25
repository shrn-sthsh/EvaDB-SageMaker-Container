#!/bin/sh

# This script runs a Docker container using the specified image.
# It mounts the local 'test_dir' directory to the '/app/learning' directory inside the container,
# maps port 8080 from the host to port 8080 in the container, and removes the container after execution.

# Extract the image name from the command-line argument
image=$1

# Run a Docker container with the following options:
# -v: Mount the 'test_dir' directory from the current host into '/app/learning' inside the container
# -p: Map port 8080 from the host to port 8080 in the container
# --rm: Remove the container after it exits
# ${image}: Use the specified Docker image
# serve: Run the 'serve' command inside the container
docker run -v $(pwd)/test_dir:/app/learning -p 8080:8080 --rm ${image} serve
