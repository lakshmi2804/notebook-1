
# Jenkins Notebook-Copy Pipeline

## Description
              
The intent of this repository is to provide Data Engineer and Data Scientist who use Databricks a quick guide on how to use Jenkins notebook-copy pipeline to deploy Databricks notebooks.

## Dockerfile

Dockerfile is used to build up  our own custom image with specific requirements. The Docker image builds up with base ubuntu:latestversion, This Dockerfile will install Git, Python3.7, Databricks-cli, jq, curl and also the latest verion of pip. Then we build up the image and pushed to Dockerhub using below docker commands.

`docker build -t test/python3-pip-databricks:1 .` 

'.' represents the Dockerfile is present in current directory and -t represents tag name.Then after building up the image we have to push to Dockerhub.Before pushing to the Dockerhub we have to login Dockerhub with your credentials in local machine where the image is build.

`docker login --username Username --password Password`

This will login to your Dockerhub and provide access to push the images we build up locally.

`docker push test/python3-pip-databricks:1`

Finally this will push our image to Dockerhub 

## Jenkinsfile

**Scripted pipeline**

The Jenkinsfile starts with scripted pipeline having master node where it will be used to perform which user is currently running the job and then assigning the user to a specific variable `BUILD_TRIGGER_BY`.
Later on finding the user and we are cleaning up the workspace which is used for the previous build.

**Declarative pipeline**

After using the scripted pipeline we moved to declarative pipeline.Where we are defining the some environment variables which are to be used in the pipeline.The variables we defined based on our requirement are `databricks_url, databricks_token, buildType, sample, test, approvalMap`.Each variable has its own specific task to be performed under the stages of pipeline.After defining the variables we start our pipeline code 

**Agent Section**

Though it's clearly mentioned our pipeline needs to be run in docker we making agent as docker and image used here is which we previously builded up and pushed to our Dockerhub (i.e test/python3-pip-databricks:1) and we are passing arguments to docker to run as root user (i.e; args '-u root').

**Parameters Section**

After the agent section we then moved to paramters section which are to be passed by the user who is running the job.These parameters will be helpful to find the git repository and the notebook files which needs to be copied from git to databricks workspace.The parameters which the user needs to be passed are

`Git_Repo_Url` : User needs to give the github repository url where the notebook files are present

`Git_Branch` : After passing the repo url user must have to pass the gitbranch because the github will have multiple branches 

`Git_credentialsId` : For accessing the github using jenkins you must need to provide the password or authorized token

`Notebook_Path_in_Git` : We must provide the absolute path of notebook files present in the github

`Target_Path_in_Databricks` : Then provide the target path that means the databricks workspace path

`Environment` : The user also needs to specify the target environment whether it could be `Test` or `Prod`

`Databricks_Token` : Here the databricks token needs to be passed for accessing the databricks workspace

`Approver_Email` : This parameter is only used for approval whenever the user needs to copy file to `Prod`

**Environment Variables**

In this section we will store the credentials or tokens in encrypted form. Mainly we are passing git token and databricks token these will be encrypted  by not seeing them in the console output.

**Options**

Here we are using only two options they are

`ansiColor` : This is the plugin mainly used for colors in jenkins console output

`timeout` : This will be helpfull to exit or abort the job after a particular time

**Stages**

###### Gitclone

In this stage we are running a bash script file for the git cloning proccess. All the git clone process commands are written in `folder_script.sh` file.And this file is also present in our github repository. The code present in folder_script.sh is

First we are passing some command line arguments to the script file (i.e; Git_Repo_Url, Git_Branch, Git_credentialsId, $WORKSPACE). $WORKSPACE is the jenkins workspace path where the jenkins job is running.The procedure we followed in the script file is first calling the command line arguments to specific variables and by following some cut commands we picked the repo name from the git repo url and also the branch (specifically when the branch name contains '/' EX:test/test1/test2),Then we created two directories using `mkdir` command (directories created are testing and subset) and after creating the directories we copied testing directory to subset directory and then `cd` to 'subset'.After changing to subset directory we moved to git clone process using the command 

`git clone https://$GitToken@$Git_Url`

This will clone the repository and all cloned files will be created under repo named folder in subset folder present in jenkins workspace.After the cloning process we again back to workspace and copy the cloned folder to another folder which is named as the git branch name (i.e; $Git_Branch in bash file) and finally moved to that folder and trying to do checkout process to know whether we are in the exact path or not

`git checkout $Git_Branch`

This will checkout the gitbranch and at last we are cross checking by running `ls -lrt` command.

Then we are configuring the approver mail in the post conditions.In these configuration also we are checking two conditions whether the mails needs to be sent or no need for these we are writing an if block statement (i.e; if the "${params.Approver_Email}" is Not Applicable then we don't need to sent a mail whether the "${params.Approver_Email}" is any recipient then we have to sent a mail to that recipient).

###### Approver

Approver mail or input needs to send or asked only when the job is configured to `Prod` environment,if the job is configured to `Test` environment then we don't need to send an email or ask for an input.Here we created an input button whether the job needs to be 'Approve' or 'Reject'.And also here we are checking the approver name also,suppose if the approver is not belongs to any of the mail we sent or specific jenkins user-id then the job must be aborted by raising an error that "unauthorized user for aprroval".If the approver belongs to mail we sent or jenkins user-id then the job must process to the further stages.After confirming the approver we also have to check another condition that the input is 'Reject'.If it is rejected then also we must have to abort the job by throwing an error "Approver has rejected the Deployment".If the input is 'Approve' and also the specific jenkins user-id or the recipient then we must have to call the function where the copy of notebook files from source to destination path and also configuring the target environment.

