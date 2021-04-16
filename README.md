
# Jenkins Notebook-Copy Pipeline

## Description
              
The intent of this repository is to provide Data Engineer and Data Scientist who use Databricks a quick guide on how to use Jenkins notebook-copy pipeline to deploy Databricks notebooks.

## Dockerfile

Dockerfile is used to build up  our own custom image with specific requirements. The Docker image builds up with base ubuntu:latestversion, This Dockerfile will install Git, Python3.7, Databricks-cli, jq, curl and also the latest verion of Pip

## Jenkinsfile

The Jenkinsfile starts with master node where it will be used to perform which user is currently running the job and then assigning the user to a specific variable
`BUILD_TRIGGER_BY`.
Later on finding the user and we are cleaning up the workspace which is used for the previous build.



