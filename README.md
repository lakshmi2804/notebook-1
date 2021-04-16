
# Jenkins Notebook-Copy Pipeline

## Description
              
The intent of this repository is to provide Data Engineer and Data Scientist who use Databricks a quick guide on how to use Jenkins notebook-copy pipeline to deploy Databricks notebooks.

## Dockerfile

Dockerfile is used to build up  our own custom image with specific requirements. The Docker image builds up with base ubuntu:latestversion, This Dockerfile will install Git, Python3.7, Databricks-cli, jq, curl and also the latest verion of pip. Then we build up the image and pushed to Dockerhub using below docker commands.

`docker build -t my-private-repo .` 

'.' represents the Dockerfile is present in current directory and -t represents tag name.Then after building up the image we have to push to Dockerhub.Before pushing to the Dockerhub we have to login Dockerhub with your credentials in local machine where the image is build.

`docker login --username Username --password Password`

This will login to your Dockerhub and provide access to push the images we build up locally.

`docker push my-private-repo`

Finally this will push our image to Dockerhub 

## Jenkinsfile

The Jenkinsfile starts with master node where it will be used to perform which user is currently running the job and then assigning the user to a specific variable
`BUILD_TRIGGER_BY`.
Later on finding the user and we are cleaning up the workspace which is used for the previous build.



