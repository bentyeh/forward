#!/bin/bash
#
# Ends a remote sbatch jobs and closes port forwarding.
# 
# Usage: bash end.sh [params_file] [NAME]
# - params_file: path to sbatch job parameters file. default = params.sh
# - NAME: SLURM job name. If not given as an argument, taken from params_file.
# 
# Sample usage                      # Assumptions
#   bash end.sh                     # params.sh exists; NAME is set by params.sh
#   bash end.sh jupyter             # params.sh exists
#   bash end.sh tensorboard         # params.sh exists
#   bash end.sh my_params.sh        # NAME is set by my_params.sh
#   bash end.sh my_params.sh my_job
#
# Expected variables set in params_file:
# - RESOURCE
# - USERNAME
# - PORT
# - NAME

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
[ -z $NAME ] && echo "Need to give NAME of sbatch job to kill!" 1>&2 && exit 1

echo "Killing $NAME slurm job on ${RESOURCE}"
ssh ${RESOURCE} "squeue --name=$NAME --user=$USERNAME -o '%A' -h | xargs --no-run-if-empty /usr/bin/scancel"

echo "Killing listeners on ${RESOURCE}"
if [ "${RESOURCE}" = "sherlock" ]; then
    LSOF="/usr/sbin/lsof"
else
    LSOF="/usr/bin/lsof"
fi
ssh ${RESOURCE} "$LSOF -i :$PORT -t | xargs --no-run-if-empty kill"

# lsof is not supported on WSL
# echo "Killing listeners on localhost"
# lsof -i:$LOCALPORT -t | xargs --no-run-if-empty kill
