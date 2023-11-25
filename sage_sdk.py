import sagemaker as sage

def train_and_deploy():
    # Set up SageMaker session
    session = sage.Session()

    # Get AWS account and region information
    account = session.boto_session.client("sts").get_caller_identity()["Account"]
    region = session.boto_session.region_name    

    # Create an Estimator for the EvaDB container
    evadb_instance = sage.estimator.Estimator(

        # Define the ECR image for the EvaDB container
        f"{account}.dkr.ecr.{region}.amazonaws.com/evadb_lts:latest",

        # Define SageMaker Execution Role
        "arn:aws:iam:", 1, "ml.m4.xlarge",

        # Set S3 bucket path for storing models
        output_path = f"s3://evadb-sagemaker/models/",
        sagemaker_session = session,
        base_job_name = "evadb-lts-sdk"
    )

if __name__ == "__main__":
    # Run the train_and_deploy function when the script is executed
    train_and_deploy()
