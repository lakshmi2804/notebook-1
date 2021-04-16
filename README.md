
# Jenkins Notebook-Copy Pipeline

## Description
              
The intent of this repository is to provide Data Engineer and Data Scientist who use Databricks a quick guide on how to use Jenkins notebook-copy pipeline to deploy Databricks notebooks.

## Jenkinsfile

The Jenkinsfile starts with master node where it will be used to perform which user is currently running the job and then assigning the user to a specific variable
**BUILD_TRIGGER_BY**.
Later on finding the user and we are cleaning up the workspace which is used for the previous build.

