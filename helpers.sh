#!/bin/bash
#
# Helper Functions shared between forward tool scripts

#
# Configuration
#

function verify_arguments() {
    if [ ! -z $GPU ] && [ $GPU -gt 0 ] && [[ "$CONSTRAINT" =~ "NO_GPU" ]]; then
        echo "Request for $GPU GPUs not compatible with 'NO_GPU' CONSTRAINT."
        exit 1
    fi
}

function set_forward_script() {

    FOUND="no"
    echo "== Finding Script =="

    declare -a FORWARD_SCRIPTS=("sbatches/${RESOURCE}/$SBATCH" 
                                "sbatches/$SBATCH"
                                "${RESOURCE}/$SBATCH" 
                                "$SBATCH");

    for FORWARD_SCRIPT in "${FORWARD_SCRIPTS[@]}"
    do
        echo "Looking for ${FORWARD_SCRIPT}";
        if [ -f "${FORWARD_SCRIPT}" ]
            then
            FOUND="${FORWARD_SCRIPT}"
            echo "Script      ${FORWARD_SCRIPT}";
            break
        fi
    done
    echo

    if [ "${FOUND}" == "no" ]
    then
        echo "sbatch script not found!!";
        echo "Make sure \$RESOURCE is defined" ;
        echo "and that your sbatch script exists in the sbatches folder.";
        exit
    fi

}

#
# Job Manager
#

function check_previous_submit() {

    echo "== Checking for previous notebook =="
    PREVIOUS=`ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o "%R" -h`
    if [ -z "$PREVIOUS" -a "${PREVIOUS+xxx}" = "xxx" ]; 
        then
            echo "No existing ${NAME} jobs found, continuing..."
        else
        echo "Found existing job for ${NAME}, ${PREVIOUS}."
        echo "Please end.sh before using start.sh, or use resume.sh to resume."
        exit 1
    fi
}


function set_partition() {

    if [[ "${PARTITION}" =~ "gpu" ]] || { [ ! -z $GPU ] && [ $GPU -gt 0 ]; }; then
        echo
        echo "== Requesting GPU =="
        echo "${GPU}"
        PARTITION="${PARTITION} --gres gpu:${GPU}"
    fi
}

function get_machine() {

    TIMEOUT=${TIMEOUT-1}
    ATTEMPT=0

    echo
    echo "== Waiting for job to start, using exponential backoff =="
    [ -z ${MINATTEMPTS} ] && MINATTEMPTS=3

    ALLOCATED="no"
    while [[ $ALLOCATED == "no" ]]; do

        read JOBID MACHINE <<< `ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o \"%i %N\" -h`

        if [ -z $JOBID ] && [ ${ATTEMPT} -gt ${MINATTEMPTS} ]; then
            echo "No job with name $NAME and user $USERNAME on $RESOURCE found."
            exit
        fi

        if [[ "$MACHINE" != "" ]]; then
            echo "Attempt ${ATTEMPT}: resources allocated to ${MACHINE}!.."  1>&2
            ALLOCATED="yes"
            break
        fi

        echo "Attempt ${ATTEMPT}: not ready yet... retrying in $TIMEOUT.."  1>&2
        sleep $TIMEOUT

        ATTEMPT=$(( ATTEMPT + 1 ))
        if [ -z ${MAXTIMEOUT} ] || [ ${TIMEOUT} -lt ${MAXTIMEOUT} ]; then
            TIMEOUT=$(( TIMEOUT * 2 ))
        fi

    done

    MACHINE="`ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o "%R" -h`"

    # If we didn't get a node...
    if ([[ "${RESOURCE}" = "sherlock" ]] && [[ "$MACHINE" != "sh"* ]]) ||
       ([[ "${RESOURCE}" = "rice" ]] && [[ "$MACHINE" != "wheat"* ]] && [[ "$MACHINE" != "oat"* ]]); then
        echo "Tried ${ATTEMPT} attempts! Job was either never enqueued or finished running already." 1>&2
        exit 1
    fi
}


#
# Instructions
#


function instruction_get_logs() {
    echo
    echo "== View logs in separate terminal =="
    echo "ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${NAME}.out"
    echo "ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${NAME}.err"
}

function print_logs() {

    ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${NAME}.out
    ssh ${RESOURCE} cat $RESOURCE_HOME/forward-util/${NAME}.err

}

#
# Port Forwarding
#

function setup_port_forwarding() {

    echo
    echo "== Setting up port forwarding =="
    sleep 5
    echo "ssh -Nf -L localhost:$LOCALPORT:$MACHINE:$PORT ${RESOURCE}"
    ssh -Nf -L localhost:$LOCALPORT:$MACHINE:$PORT ${RESOURCE} &

}
