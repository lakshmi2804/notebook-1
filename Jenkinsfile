node('master') {
               BUILD_TRIGGER_BY = "${currentBuild.getBuildCauses()[0].shortDescription}"
               echo "BUILD_TRIGGER_BY: ${BUILD_TRIGGER_BY}"
	       cleanWs()
}
def databricks_url
def databricks_token
//def Environment = params.Environment
def buildType
def sample
def test
def approvalMap
pipeline {
	agent {
		docker {
			image 'test/python3-pip-databricks:1'
			args '-u root'
		}
	}
	parameters {
		choice(choices: ['Test', 'Prod'], description: 'Select the Databricks environment', name: 'Environment')
		choice(choices: ['Not Applicable', 'email@.com', 'email@.com', 'email@.com'], description: "Select the Approver's Email ID for Production Deployment", name: 'Approver_Email')
                string(name: 'Databricks_Token', defaultValue: '', description: 'Enter the Databricks personal access token for the environment selected')
                string(name: 'Git_Repo_Url', defaultValue: '', description: 'Enter the Git Repo URL')
		string(name: 'Git_Branch', defaultValue: '', description: 'Enter the Git branch to checkout')
                string(name: 'Git_credentialsId', defaultValue: '', description: 'Enter the Git credentials id saved in jenkins')
                text(name: 'Notebook_Path_in_Git', description: 'Enter the notebook path in Git Repo ')
                text(name: 'Target_Path_in_Databricks', description: 'Enter the target path to copy notebook')
 
	}
	environment {
		Git_credentialsId = credentials("${params.Git_credentialsId}")
                Databricks_Test_Token = credentials("${params.Databricks_Token}")
	}
	options {
		ansiColor('xterm')
		timeout(time: 24, unit: 'HOURS') 
	}
         stages {
                  stage('Databricks Copy file to target') {
                           steps {
				   script{
					   sh """
					   echo "$BUILD_TRIGGER_BY" >> $WORKSPACE/folder1.sh
					   cat $WORKSPACE/folder1.sh
					   """
					   echo "${env.git_url}"
					   echo "$WORKSPACE"
					   sh "pwd"
                                    	   echo "$Notebook_Path_in_Git"
					   echo "$Target_Path_in_Databricks"
					   echo "just copying file from logging to copying"
					   sh """
					   sh $WORKSPACE/notebook-copy/folder_script.sh "${params.Git_Repo_Url}"  "\$Git_credentialsId" "${params.Git_Branch}" $WORKSPACE
					   
					   """
					 //  git branch: "${params.Git_Branch}", credentialsId:  "${params.Git_credentialsId}", url: "${env.git_url}"
					   //sh "git branch -a"
				           //sh "ls -lrt"
					 //  sh """
					   //sh /var/lib/jenkins/notebook-copy-test.sh "${params.Notebook_Path_in_Git}" $WORKSPACE
					   //"""
                                             //sh """
                                          //   sh /var/lib/jenkins/notebook-copy.sh "${Notebook_Path_in_Git}" "${Target_Path_in_Databricks}" "$WorkSpace"

                                            // """
                                   // script{
                                     //        buildType = "${params.Environment}"
                                       //      echo "$buildType"
                                         //    createBuilds(buildType)
                                    //}
				   }
                           }
			  post {
				  always {
					  echo "Approval Needed!"
					  echo 'post->Approval Needed'
					  script{
						  if ( "${params.Approver_Email}" == "Not Applicable" ){
							  echo "No need for Approval"
						  }
						  if ( "${params.Approver_Email}" != "Not Applicable" ) {
							  mail to: "${params.Approver_Email}",
								  subject: "Approval Needed for Production Deployment: Build ${env.JOB_NAME}", 
								  body: "Approval Needed for Production Deployment ${env.JOB_NAME} build no: ${env.BUILD_NUMBER}\n\nPlease click on the below link for Approval:\n ${env.BUILD_URL}\\input\n\n Git Repo : ${params.Git_Repo_Url}\n\n Branch : ${params.Git_Branch}\n\n Lambda Function Name :${params.Lambda_Function_Name}\n\n Lambda Deployment :${params.LambdaDeployment} "
						  }
					  }
					                 
				  }
			  }
                  }
		 stage('Approval') {
			 agent none
			 steps {
				 script {
					 if ( "${params.Environment}" == "Prod" ){
						 def USER_INPUT = input(
							 message: 'User input required -  Approval or Rejected?',
							 submitterParameter: 'APPROVER',
							 parameters: [
								 [$class: 'ChoiceParameterDefinition',
								  choices: ['Approve','Reject'].join('\n'),
								  name: 'Selection',
								  description: " \nGit Repo : ${params.Git_Repo_Url}\n\n Branch : ${params.Git_Branch}\n\n Source Path :\n${params.Notebook_Path_in_Git}\n\n Destination :\n${params.Target_Path_in_Databricks}\n\n "]
							 ])
						 test = "${USER_INPUT['Selection']}"
						 test1 = "${USER_INPUT['APPROVER']}"
						 if ( "$test" == "Approve" ){
							 if ( "$test1" == "aswin-katuri" || "$test1" == "email@.com"){
								 buildType = "${params.Environment}"
								 echo "$buildType"
								 createBuilds(buildType)
							 }
							 if ( "$test1" == "bhanushali-jignesh" || "$test1" == "email@.com"){
								 buildType = "${params.Environment}"
								 echo "$buildType"
								 createBuilds(buildType)
							 }
							  if ( "$test1" == "sandeep-golla" || "$test1" == "email@.com"){
								 buildType = "${params.Environment}"
								 echo "$buildType"
								 createBuilds(buildType)
							 }
							 if ( "$test1" != "usernew" && "$test1" != "user1" && "$test1" != "user2" && "$test1" != "user3" && "$test1" == "email@.com" && "$test1" != "email@.com"){
								 error("unauthorized user for aprroval")
							 }
						 }
						 if ( "$test" == "Reject" ){
							 error("Approver has rejected the Deployment")
						 }
							 
					 }
					 else{
						 buildType = "${params.Environment}"
						 echo "$buildType"
						 createBuilds(buildType)
					 }
				 }
			 }
		 }
	 }
         post {
		 success {
			echo "Deployement  Success!"
			echo 'post->success is called'
			mail to: 'email@.com',
			subject: "Jenkins Build SUCCESSFUL: Build ${env.JOB_NAME}", 
				body: "Databricks Notebooks Migration - Successfully Completed ${env.JOB_NAME} build no: ${env.BUILD_NUMBER}\n\nView the log at:\n ${env.BUILD_URL}\n\nBlue Ocean:\n${env.RUN_DISPLAY_URL}"
                            
                        }
		failure {
			echo "Deployement  Failed!"
			echo 'post->Failed is called'
			mail to: 'email@.com',
			subject: "Jenkins Build FAILED: Build ${env.JOB_NAME}", 
				body: "Databricks Notebooks Migration - Failed ${env.JOB_NAME} build no: ${env.BUILD_NUMBER}\n\nView the log at:\n ${env.BUILD_URL}\n\nBlue Ocean:\n${env.RUN_DISPLAY_URL}"      
                        }
		always { 
			cleanWs()
		}
	 }
}

def createBuilds(thestage){ 
    stage("Deploying on"+" "+thestage) {
	    if(thestage.contains("Test")){
		    echo "deploying on test"
		    echo "${params.Databricks_URL}"
		    echo "${params.Databricks_Token}"
		    sh '> ~/.databrickscfg'
		    sh 'echo "$Databricks_Test_Token"'
		    sh 'echo "[DEFAULT]" >> ~/.databrickscfg'
		    sh "echo 'host=https://test.databricks.com' >> ~/.databrickscfg"
		    sh 'echo "token=\$Databricks_Test_Token" >> ~/.databrickscfg'
		    sh """
		    sh $WORKSPACE/notebook-copy/notebook-copy-new.sh "${params.Notebook_Path_in_Git}" "${params.Target_Path_in_Databricks}" $WORKSPACE "${params.Git_Repo_Url}" "${params.Git_Branch}" $BUILD_TRIGGER_BY
		    """
	    }
	    if(thestage.contains("Prod")){
		    echo "deploying on prod"
		    echo "deploying on test"
		    echo "${params.Databricks_URL}"
		    echo "${params.Databricks_Token}"
		    sh '> ~/.databrickscfg'
		    sh 'echo "$Databricks_Test_Token"'
		    sh 'echo "[DEFAULT]" >> ~/.databrickscfg'
		    sh "echo 'host=https://prod.databricks.com' >> ~/.databrickscfg"
		    sh 'echo "token=\$Databricks_Test_Token" >> ~/.databrickscfg'
		    sh 'cat ~/.databrickscfg'
		    sh """
		    sh $WORKSPACE/notebook-copy/notebook-copy-new.sh  "${params.Notebook_Path_in_Git}" "${params.Target_Path_in_Databricks}" $WORKSPACE "${params.Git_Repo_Url}" "${params.Git_Branch}" $BUILD_TRIGGER_BY
		    """
	    }
    }
}
node {
	stage("cleanWs"){
		script{
			sh """
			cd $WORKSPACE
			cd ..
			ls -lrt
			#chown -R jenkins:jenkins .
			sudo find -type d -name "*ws-cleanup*" -exec rm -rf {} +
			ls -lrt
			"""
		}
	}
}
