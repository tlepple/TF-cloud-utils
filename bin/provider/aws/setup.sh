#!/bin/bash
###########################################################################################################
# import parameters and utility functions 
###########################################################################################################
. ${STARTING_DIR}/bin/provider/aws/run.properties
. ${STARTING_DIR}/bin/provider/aws/utils.sh

#####################################################
#	Step 1: install the AWS cli
#####################################################
install_aws_cli
