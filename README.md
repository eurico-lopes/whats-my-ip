# What's my IP?

Python Repository that returns your public IP.

## Philosophy behind it

The repo leverages Docker, Kubernetes, Terraform and Azure Pipelines to deploy an application locally that returns the public IP.

* It is using Azure Pipelines with a self-hosted agent.
* Since the only available agent is my machine, whenever the pipeline is triggered, it will run in my machine.
* As it is running in my machine, the agent will have access to containers and the kubernetes cluster running in my machine as well.
* By using a containerized S3 bucket and DynamoDB (localstack image), I can have these 2 services available for both my machine, and the ci process.
* As such, by overriding the Terraform endpoints of the S3 backend, I can simulate a real environment, where it is possible to run terraform commands from my local machine and from the ci process with the exact same result.

Even though, the application is only being deployed to the local Kubernetes cluster, the application code can be deployed to a publicly available K8s cluster and still work.

## Components

1. k8s - holds the kubernetes manifests with templating
    1. the manifests have some variables that are substituted by running the terraform apply
    2. as an alternative, one can also use `envsubst` to generate the manifests from the templates
    3. Composed of a namespace, nodeport and deployment with 3 replicas.
2. local - resources to deploy local AWS services and create a bucket and a dynamoDB table
    1. runs a localstack container with AWS services
    2. runs an accessory container to create the local s3 bucket and dynamodb that will be used by Terraform to store state
3. pipelines - contains a ci pipeline declaration to be used in Azure Pipelines
    1. declares a lint, a test, build and push step and a deploy push
    2. it is triggered when changes are pushed to the master branch.
    3. it requires a self-hosted agent to run, where the agent pool is called MyComputer
4. requirements - dependencies for our application
    1. install dev.pip when developing locally
    2. install test.pip when running the tests
    3. install prod.pip with the dependencies to run the application
5. scripts - scripts to get the current tag, to run the tests in docker and to build and push a Docker image to a repository
    1. get-tag.sh gets the HEAD commit hash in the short version
    2. run-tests.sh builds the test image and runs it
    3. build-and-deploy-docker-image.sh builds the image with the appropriate TAG and pushes it to a remote repository
6. src - contains the Python and Flask code that actually returns the public IP
    1. Tests are using pytest as the testing framework.
    2. Application code is using Python and Flask to return an HTML Page with the public IP in case of success or an error message in case of failure.
7. terraform - contains the terraform files that maintain the state of the kubernetes objects
    1. used to deploy to local kubernetes cluster
    2. State is stored locally and in an S3 Bucket of the container localstack
    3. Whenever the ci runs as an agent in my machine, it is able to connect to the localstack container and get the state from there, emulating a real environment.
8. Dockerfile - file that packages the application
    1. One stage to package the tests
    2. One stage to package the application code

## Running things locally

Requirements:
* Have terraform installed
* Have Docker installed and a local Kubernetes cluster available (e.g. Docker Desktop)

The first command of each code block is asdumed to be run from the root of the repo.

Running the tests locally:
```bash
cd scripts/ && sh run-tests.sh
```

Deploying an image to your DockerHub:
```bash
cd scripts/ && DOCKER_ID=<your-docker-id> DOCKER_PASSWORD=<your-docker-password> build-and-deploy-docker-image.sh
```

Run terraform commands to deploy the kubernetes resources:
```bash
cd local/ && docker-compose up
cd ../terraform
export AWS_ACCESS_KEY_ID=nothing AWS_SECRET_ACCESS_KEY=nothing
terraform init
terraform plan -var docker_id=<your-docker-id>
terraform apply -var docker_id=<your-docker-id>
```

