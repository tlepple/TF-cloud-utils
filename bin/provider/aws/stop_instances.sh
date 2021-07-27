#########################################################
#   load some utility functions
#########################################################

STARTING_DIR=`pwd`
# logging function
log() {
    echo -e "[$(date)] [$BASH_SOURCE: $BASH_LINENO] : $*"
}


#########################################################
# load the util functions and properties files:
#########################################################
log "load setup"
. ${STARTING_DIR}/bin/provider/aws/run.properties
log "load utils"
. ${STARTING_DIR}/bin/provider/aws/utils.sh

#####################################################
# check if all necessary parameters have been exported
#####################################################
log "check aws credentials"
if [ "${AWS_ACCESS_KEY_ID}" = "" ] || [ "${AWS_SECRET_ACCESS_KEY}" = "" ]; then
  log "AWS credentials have not been exported. Please export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY and try again. Exiting..."
  exit 1
fi
log "check region"
if [ "${AWS_DEFAULT_REGION}" = "" ]; then
  log "AWS_DEFAULT_REGION has not been exported.\n\nPlease export AWS_DEFAULT_REGION and try again. Exiting..."
  exit 1
fi

#########################################################
# loop through array and echo the ID
#########################################################

log "begin loop"
for VALUE in ${EC2_INSTANCES[@]}; do
     echo "Instance id is -->     " ${VALUE}
     export RUN_STATE=$(aws ec2 describe-instances --instance-ids ${VALUE} \
     --query Reservations[].Instances[].State.Code \
     --output text)
     echo
     echo "Current run state is: "$RUN_STATE


     if (( $RUN_STATE == 16 ));
     then
        echo "Instance " ${VALUE} " is Running"
        echo
#          # Time to stop the instance:
	echo "Stopping instanceID = " ${VALUE}
	aws ec2 stop-instances --instance-ids ${VALUE}
     else
        echo "Instance " ${VALUE} " is in a different state."
        echo
     fi
echo
#    This stop check isn't working... to do
#     check_ec2_stopping ${VALUE}

done

log "script complete"

