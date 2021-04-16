
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

**Gitclone**

In this stage we are running a bash script file for the git cloning proccess. All the git clone process commands are written in `folder_script.sh` file.And this file is also present in our github repository. The code present in folder_script.sh is

First we are passing some command line arguments to the script file (i.e; Git_Repo_Url, Git_Branch, Git_credentialsId, $WORKSPACE). $WORKSPACE is the jenkins workspace path where the jenkins job is running.The procedure we followed in the script file is first calling the command line arguments to specific variables and by following some cut commands we picked the repo name from the git repo url and also the branch (specifically when the branch name contains '/' EX:test/test1/test2),Then we created two directories using `mkdir` command (directories created are testing and subset) and after creating the directories we copied testing directory to subset directory and then `cd` to 'subset'.After changing to subset directory we moved to git clone process using the command 

`git clone https://$GitToken@$Git_Url`

This will clone the repository and all cloned files will be created under repo named folder in subset folder present in jenkins workspace.After the cloning process we again back to workspace and copy the cloned folder to another folder which is named as the git branch name (i.e; $Git_Branch in bash file) and finally moved to that folder and trying to do checkout process to know whether we are in the exact path or not

`git checkout $Git_Branch`

This will checkout the gitbranch and at last we are cross checking by running `ls -lrt` command.

Then we are configuring the approver mail in the post conditions.In these configuration also we are checking two conditions whether the mails needs to be sent or no need for these we are writing an if block statement (i.e; if the "${params.Approver_Email}" is Not Applicable then we don't need to sent a mail whether the "${params.Approver_Email}" is any recipient then we have to sent a mail to that recipient).

**Approver**

Approver mail or input needs to send or asked only when the job is configured to `Prod` environment,if the job is configured to `Test` environment then we don't need to send an email or ask for an input.Here we created an input button whether the job needs to be 'Approve' or 'Reject'.And also here we are checking the approver name also,suppose if the approver is not belongs to any of the mail we sent or specific jenkins user-id then the job must be aborted by raising an error that "unauthorized user for aprroval".If the approver belongs to mail we sent or jenkins user-id then the job must process to the further stages.After confirming the approver we also have to check another condition that the input is 'Reject'.If it is rejected then also we must have to abort the job by throwing an error "Approver has rejected the Deployment".If the input is 'Approve' and also the specific jenkins user-id or the recipient then we must have to call the function where the copy of notebook files from source to destination path and also configuring the target environment.The post conditions are also be written under approval stage beacuse the calling function is present outside the Declarative pipeline.In the post conditions we have three steps i.e; on success we have to sent an email that the job is geeting succedded and on failure we must have to sent an email that the job has been failed and finally whether the job is success or failure we must follow always condition to clean the jenkins job workspace to avoid errors for the nextbuild.

**Test or Prod**

In this stage we must have to provide the stage name as the environment name which is selected at parameters.In this stage also first we have to check whether it is `Test` or `Prod` environment and then we have to congifure the databricks according to the specified environment.Before doing the databricks configuration we must have to install databricks cli on our jenkins machine.Then if the specified environment is `Test` then we proceed to configure the `Test` environment configuration by passing the databricks url and databricks token.And the same procedure must be followed for the `Prod` environment.Configuring databricks is like

First me must have to delete the previous configuration present in .databrickscfg.The below command will do that specific action if the file is not present then it will be created

`sh '> ~/.databrickscfg'`

`sh 'echo "$Databricks_Test_Token"'`

The below commands are used to configure databricks cli in our machine to run databricks cli commands

`sh 'echo "[DEFAULT]" >> ~/.databrickscfg'`

`sh "echo 'host=https://test.databricks.com' >> ~/.databrickscfg"`

`sh 'echo "token=\$Databricks_Test_Token" >> ~/.databrickscfg'`

In the same way we can configure the `Prod` environment.After setting up the configurations we again wrote a bash file (i.e; `notebook-copy-new.sh`)which contains copy of code in shell script to copy files from source path (i.e; github) to the destination (i.e; databricks workspace).This script should also be present in the same gitrepo where the jenkins file is present.while running the script file we must have to pass some command line arguments(i.e; Notebook_Path_in_Git, Target_Path_in_Databricks, Git_Branch, Git_Url, WORKSPACE).First the script file call these arguments and assign them to some variables.Then we must have to create a backup directory with the timestamp.It is used to backup the notebook files.Then we will run a for loop to iterate how many number of notebooks to copied and these will be stored in test1 file which is to be created during the execution.In the same way we will run an another for loop to iterate the destination path and it will be copied to test2 file which is also to be created during the execution.After these two for loops we will run another loop to have one to one mapping between sourcepath and the targetpath,in the loop itself we are checking a condition that notebook is a single file or multiple notebook files under single directory to be copied.If it is a directory then we must have to copy files from databricks workspace to our local backup directory and then we have to delete all the files present in the targetpath if it is directory and then we have to copy files from github to databricks worksapce.If it is a file then it not be deleted but it must be copied to our local backup folder and then it must be copied or update the target file.After copying the notebook files then we must have to copy the backup folder to the target folder backup folder with folder name as user(i.e; user who runs the jenkins job) with the timestamp.Here the docker container will stop and it will be exited.

**CleanWs**

This will be begins with an another node this is not a part of declarative pipeline.While we are running docker agent with root user some untracked directories are being backedup to jenkins workspace while cleaning the job workspace.To delete those untracked directories we are using an another node.In this node first we are finding where the untracked directories are being present using the `find` command and deleting the directories which are found.

`sudo find -type d -name "*ws-cleanup*" -exec rm -rf {} +`

This command will find the directories who has name "ws-cleanup" and then forcefully deleting those directories






