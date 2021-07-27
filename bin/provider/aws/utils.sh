#!/bin/bash

#####################################################
# Function to install jq
#####################################################

install_jq_cli() {

	#####################################################
	# first check if JQ is installed
	#####################################################
	echo "Installing jq"
	yum install -y unzip

	jq_v=`jq --version 2>&1`
	if [[ $jq_v = *"command not found"* ]]; then
	  curl -L -s -o jq "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
	  chmod +x ./jq
	  cp jq /usr/bin
	else
	  echo "jq already installed. Skipping"
	fi

	jq_v=`jq --version 2>&1`
	if [[ $jq_v = *"command not found"* ]]; then
	  #log "error installing jq. Please see README and install manually"
	  echo "Error installing jq. Please see README and install manually"
	  exit 1 
	fi  

}


#####################################################
# Function to install aws cli
#####################################################

install_aws_cli() {

	#########################################################
	# BEGIN
	#########################################################
	echo "BEGIN setup.sh"
	yum install -y unzip less groff-base


	#####################################################
	# first check if JQ is installed
	#####################################################
	echo "Installing jq"

        jq_v=`jq --version 2>&1`
        if [[ $jq_v = *"command not found"* ]]; then
          curl -L -s -o jq "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
          chmod +x ./jq
          cp jq /usr/bin
        else
          echo "jq already installed. Skipping"
        fi

        jq_v=`jq --version 2>&1`
        if [[ $jq_v = *"command not found"* ]]; then
          echo "Error installing jq. Please see README and install manually"
          exit 1
        fi

	####################################################
 	# then install AWS CLI
	#####################################################
  	echo "Installing AWS_CLI"
  	aws_cli_version=`aws --version 2>&1`
  	echo "Current CLI version: $aws_cli_version"
  	if [[ $aws_cli_version = *"aws-cli"* ]]; then
    		echo "AWS CLI already installed. Skipping"
    		return
#  	fi
        else
  		curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  		unzip awscliv2.zip
  		./aws/install -i /usr/local/aws -b /usr/local/bin 
  		rm -rf aws*
  	echo "Done installing AWS CLI v2"
        fi
}


#####################################################
# Function to check ec2 instance is ready
#####################################################
check_ec2_starting(){
  log "Checking Start status of this instance... sleeps for 60s"
  sleep 60s
  stage=`aws --output json --region ${AWS_DEFAULT_REGION:?} ec2 describe-instance-status --instance-ids $1 | jq -r ".InstanceStatuses[0].InstanceStatus.Status"`

  while [ "$stage" == 'initializing' ]
  do
    log "EC2 status: $stage"
    log "sleeping for 20s"
    sleep 20
    stage=`aws --output json --region ${AWS_DEFAULT_REGION:?} ec2 describe-instance-status --instance-ids $1 | jq -r ".InstanceStatuses[0].InstanceStatus.Status"`
   
  done
  log "EC2 status: $stage"
  if [ "$stage" != 'ok' ]
  then
    log "EC2 instance not in 'OK' status. Please check the EC2 console. Exiting..."
    exit 1
  fi
#  log "ec2 instance ready"


}

#####################################################
# Function to check ec2 instance is ready
#####################################################
#  This function needs work... no way to tell if current status is stopping
check_ec2_stopping(){
  log "Checking Stop Status of this instance... sleeps for 60s"
  sleep 60s
  stage=`aws --output json --region ${AWS_DEFAULT_REGION:?} ec2 describe-instance-status --instance-ids $1 | jq -r ".InstanceStatuses[0].InstanceStatus.Status"`

  while [ "$stage" == 'stopping' ]
  do
    log "EC2 status: $stage"
    log "sleeping for 20s"
    sleep 20
    stage=`aws --output json --region ${AWS_DEFAULT_REGION:?} ec2 describe-instance-status --instance-ids $1 | jq -r ".InstanceStatuses[0].InstanceStatus.Status"`
  
  done
  log "EC2 status: $stage"
  if [ "$stage" != 'ok' ]
  then
    log "EC2 instance not in 'OK' status. Please check the EC2 console. Exiting..."
    exit 1
  fi
#  log "ec2 instance ready"


}

