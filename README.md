# EvaDB SageMaker Container
This repository contains the EvaDB containers for use with SageMaker.

This EvaDB container is intended to supports two execution modes on Amazon SageMaker. Training, where EvaDB uses input data to train a new model, and serving, where it accepts HTTP requests and uses the previously trained model to do a prediction.

STATUS: at the moment, the project in incomplete.  The container works, but training support is incomplete and serving is not fully tested.  

## Table of contents
 * [Build an image](#build-an-image)
 * [Test the container locally](#test-the-container-locally)
   * [Test directory](#test-directory)
   * [Run tests](#run-tests)
 * [Push the image to ECS](#push-the-image-to-amazon-elastic-container-service)

## Build a Docker image

After cloning into the repository, execute the following command to build the docker image:

```sh
docker build -t evadb-sagemaker-container -f Dockerfile.CUDA .
```

In the case you want to build the container locally and there is no CUDA GPU available, execute the following alternate command with a different docker file:

```sh
docker build -t evadb-sagemaker-container -f Dockerfile .
```

You can then run the container using the following command:

```sh
docker run -it evadb-sagemaker-container
```

Note `evadb-sagemaker-container` will be the name of the Docker image.

## Push the image to Amazon Elastic Container Service

Use the shell script `build-and-push.sh`, to push the latest image to the Amazon Container Services.
You can run it as:
```sh
 ./build-and-push.sh evadb-sagemaker-container 
```
The script will look for an AWS EC repository in the default region that you are using, and create a new one if that doesn't exist.
