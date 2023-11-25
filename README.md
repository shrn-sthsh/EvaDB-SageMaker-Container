# EvaDB SageMaker Container
This repository contains the EvaDB Docker containers for use on Amazon SageMaker.

This EvaDB container is intended to supports two execution modes on Amazon SageMaker. 
1. Training, where EvaDB uses user specified input data and an user defined algorithm to train a new model, and 
2. Serving, where it accepts HTTP requests and allows interaction with previously trained models.

## Table of contents
 * [Build an image](#build-an-image)
 * [Test the container locally](#test-the-container-locally)
   * [Test directory](#test-directory)
   * [Run tests](#run-tests)
 * [Push the image to ECS](#push-the-image-to-amazon-elastic-container-service)
 * [Training](#training)
   * [Parameters](#parameters)
 * [Using the SageMaker Python SDK](#using-the-sagemaker-python-sdk)
   * [Starting train job ](#starting-train-job)
   * [Deploy model and create endpoint](#deploy-model-and-create-endpoint)

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

## Test the container locally

All of the files for testing the setup are located inside the `local_test` directory.

#### Test directory

* `train_local.sh`: Instantiate the container configured for training.
* `serve_local.sh`: Instantiate the container configured for serving.

Once train_local.sh run, custom algorithm is run with outputs available as well.

#### Run tests
To train the model execute train script and specify the tag name of the docker image:
```sh
./train_local.sh mindsdb-impl
```
The train script will use the dataset that is located in the `input/data/training/` directory.

Then start the server:
```sh
./serve_local.sh mindsdb-impl
```

## Push the image to Amazon Elastic Container Service

Use the shell script `build-and-push.sh`, to push the latest image to the Amazon Container Services.
You can run it as:
```sh
 ./build-and-push.sh evadb-sagemaker-container 
```
The script will look for an AWS EC repository in the default region that you are using, and create a new one if that doesn't exist.

## Training 
When making a training job, Amazon SageMaker sets up the environment, performs the training, then store the model artifacts in the location you specified when the job was made.

### Parameters
* **Algorithm source**: Make `your own algorithm` using `algorithm.py` and provide the registry path where the EvaDB image is stored in Amazon ECR  `846763053924.dkr.ecr.us-east-1.amazonaws.com/evadb_instance`
* **Input data configuration**: Choose S3 as a data source and provide path to the backet where the dataset is stored e.g
s3://bucket/path-to-your-data/
* **Output data configuration**: This would be the location where the model artifacts will be stored on s3 e.g
s3://bucket/path-to-write-models/

### Starting train job 
The SageMaker Estimator defines how you can use the container to train. There is an example script called `sage_sdk.py` in the root directory of the repository.

### Deploy model
The model can be deployed to SageMaker by calling deploy method.
```python
predictor = evadb_instance.deploy(1, 'ml.m4.xlarge', endpoint_name='evadb-instance')
```
The deploy method configures the Amazon SageMaker hosting services endpoint, deploy model and launches the endpoint to host the model. It returns RealTimePredictor object, from which you can get the predictions from.
```python
with open('data/*', 'r') as reader:
    data = reader.read()
predictor.predict(data).decode('utf-8')
```
The predict endpoint accepts test datasets in CSV, Json, Excel data formats.
Note here the `*` in the path must be replace with the desired data.

