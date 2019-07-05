#!/bin/bash
#
# Starts a remote sbatch jobs and sets up correct port forwarding.
# 
# Usage: bash start.sh [params_file] [SCRIPT]
# - params_file: path to sbatch job parameters file. default = params.sh
# - RESOURCE: server / cluster, e.g., rice or sherlock
# - SCRIPT: filename of sbatch script
#     Checks the following directories for $SCRIPT.sbatch:
#     - . (current working directory)
#     - ./sbatches
#     - ./sbatches/${RESOURCE}
#     - ./${RESOURCE}
#     See set_forward_script() in helpers.sh.
#
# Sample usage                                  # Assumptions
#   bash start.sh jupyter                       # params.sh exists
#   bash start.sh sherlock/singularity-jupyter  # params.sh exists
#   bash start.sh my_params.sh                  # NAME is set in my_params.sh
#   bash start.sh my_params.sh jupyter
# 
# Expected variables set in params_file:
# - RESOURCE
# - PORT
# - LOCALPORT
# - [optional] NAME
# - [optional] SCRIPT
# - [optional] PARTITION
# - [optional] MEM
# - [optional] TIME
# - [optional] EXCLUDE
# - [depends on sbatch script] WD
# - [depends on sbatch script] ENV

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
[ -z $NAME ] && echo "Need to give NAME of sbatch job to run!" 1>&2 && exit 1

if [ ! -f helpers.sh ]; then
    echo "Cannot find helpers.sh script!"
    exit 1
fi
source helpers.sh

SBATCH="$SCRIPT.sbatch"

# set FORWARD_SCRIPT and FOUND
set_forward_script
check_previous_submit

echo
echo "== Getting destination directory =="
RESOURCE_HOME=`ssh ${RESOURCE} pwd`
ssh ${RESOURCE} mkdir -p $RESOURCE_HOME/forward-util

echo
echo "== Uploading sbatch script =="
scp $FORWARD_SCRIPT ${RESOURCE}:$RESOURCE_HOME/forward-util/

# adjust PARTITION if necessary
set_partition
echo

echo "== Submitting sbatch =="

SBATCH_NAME=$(basename $SBATCH)
command="sbatch
    --job-name=$NAME
    --partition=$PARTITION
    --output=$RESOURCE_HOME/forward-util/$NAME.out
    --error=$RESOURCE_HOME/forward-util/$NAME.err
    --mem=$MEM
    --time=$TIME
    --exclude=$EXCLUDE
    $RESOURCE_HOME/forward-util/$SBATCH_NAME $PORT \"${WD}\" $ENV"

echo ${command}
ssh ${RESOURCE} ${command}

# Tell the user how to debug before trying
instruction_get_logs

# Wait for the node allocation, get identifier
get_machine
echo "notebook running on $MACHINE"

setup_port_forwarding

sleep 5
echo 
echo "== Connecting to notebook =="

# Print logs for the user, in case needed
print_logs

echo

instruction_get_logs
echo
echo "== Instructions =="
echo "1. Password, output, and error printed to this terminal? Look at logs (see instruction above)"
echo "2. Browser: http://$MACHINE:$PORT/ -> http://localhost:$LOCALPORT/..."
echo "3. To end session: bash end.sh ${params_file} ${NAME}"
