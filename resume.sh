#!/bin/bash
#
# Resumes an already running remote sbatch job.
# 
# Usage: bash resume.sh [params_file] [NAME]
# - params_file: path to sbatch job parameters file. default = params.sh
# - NAME: sbatch job name. If not given as an argument, taken from params_file.
#
# Sample usage                         # Assumptions
#   bash resume.sh                     # params.sh exists; NAME is set by params.sh
#   bash resume.sh jupyter             # params.sh exists
#   bash resume.sh my_params.sh        # NAME is set by my_params.sh
#   bash resume.sh my_params.sh my_job
#
# Expected variables set in params_file:
# - RESOURCE
# - USERNAME
# - PORT
# - LOCALPORT
# - [optional] NAME

# Unset NAME variable in case it is in use (e.g., by WSL)
unset NAME

params_file=$1
if [ ! -f "$params_file" ]; then
    params_file="params.sh"
    NAME_ARG=$1
    if [ ! -f "$params_file" ]; then
        echo "Need to configure params before first run, run setup.sh!"
        exit 1
    fi
else
    NAME_ARG=$2
fi
source "$params_file"

[ ! -z $NAME_ARG ] && NAME=$NAME_ARG
[ -z $NAME ] && echo "Need to give NAME of sbatch job to resume!" 1>&2 && exit 1

echo "Looking up existing job: ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o \"%i %T %L %C %m %N\" -h"
RESULT=`ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o \"%i %T %L %C %m %N\" -h`
read JOB_ID STATE TIME_LEFT CPU MEM MACHINE <<< "$RESULT"
if [[ -z $JOB_ID ]]; then
    echo "No job with name $NAME and user $USERNAME on $RESOURCE found."
elif [[ -z $MACHINE ]]; then
    echo "No nodes currently allocated."
    echo "Job ID: $JOB_ID. Job state: $STATE. Time remaining: $TIME_LEFT." \
         "CPUs: $CPU. Memory: $MEM."
else
    echo "Job ID: $JOB_ID. Job state: $STATE. Time remaining: $TIME_LEFT." \
         "CPUs: $CPU. Memory: $MEM. Nodelist: $MACHINE."
    echo "Resuming port forwarding: ssh -N -L localhost:$LOCALPORT:$MACHINE:$PORT $RESOURCE &"
    ssh -N -L localhost:$LOCALPORT:$MACHINE:$PORT $RESOURCE &
fi
