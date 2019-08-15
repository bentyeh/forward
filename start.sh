#!/bin/bash
#
# Starts a remote sbatch job and sets up correct port forwarding.
# 
# Usage: bash start.sh [params_file] [SCRIPT] [--no-forward]
# - params_file: path to sbatch job parameters file. default = params.sh
# - RESOURCE: server / cluster, e.g., rice or sherlock
# - SCRIPT: filename of sbatch script
#     Checks the following directories for $SCRIPT.sbatch:
#     - . (current working directory)
#     - ./sbatches
#     - ./sbatches/${RESOURCE}
#     - ./${RESOURCE}
#     See set_forward_script() in helpers.sh.
# - --no-forward: submit job but do not setup port forwarding
#
# Sample usage                                  # Assumptions
#   bash start.sh jupyter                       # params.sh exists
#   bash start.sh sherlock/singularity-jupyter  # params.sh exists
#   bash start.sh my_params.sh                  # SCRIPT is set in my_params.sh
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

# Check for "--no-forward" argument and shift arguments $1, $2, ... accordingly
# - https://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-a-bash-script
# - https://stackoverflow.com/questions/4827690/how-to-change-a-command-line-argument-in-bash
argc=$#
argv=($@)
for ((i=0; i<argc; i++)); do
    if [[ "${argv[$i]}" = "--no-forward" ]]; then
        no_forward="true"
        if [[ $i -eq 0 ]]; then
            set -- "${@:$(($i+2)):$argc}"
        else
            set -- "${@:1:$(($i))}" "${@:$(($i+2)):$argc}"
        fi
        break
    fi
done

params_file=$1
if [ ! -f "$params_file" ]; then
    params_file="params.sh"
    SCRIPT_ARG=$1
    if [ ! -f "$params_file" ]; then
        echo "Need to configure params before first run, run setup.sh!"
        exit 1
    fi
else
    SCRIPT_ARG=$2
fi
source "$params_file"

[ ! -z $SCRIPT_ARG ] && SCRIPT=$SCRIPT_ARG
[ -z $SCRIPT ] && echo "Need to give SCRIPT of sbatch job to run!" 1>&2 && exit 1
[ -z $NAME ] && NAME=SCRIPT

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
if [[ -z $SLURM_COMMAND ]]; then
    if [[ $PARTITION =~ "dev" ]]; then
        SLURM_COMMAND="srun"
    else
        SLURM_COMMAND="sbatch"
    fi
fi
command="$SLURM_COMMAND
    --job-name=$NAME
    --partition=$PARTITION
    --output=$RESOURCE_HOME/forward-util/$NAME.out
    --error=$RESOURCE_HOME/forward-util/$NAME.err
    -c $CPU
    --mem=$MEM
    --time=$TIME
    --exclude=$EXCLUDE
    $RESOURCE_HOME/forward-util/$SBATCH_NAME $PORT \"${WD}\" $ENV"

echo ${command}
if [[ $SLURM_COMMAND = "srun" ]]; then
    # cannot capture output of srun job submission (e.g., RESULT=`ssh ${RESOURCE} ${command} 2>&1`)
    # and separately wait for job allocation, since srun is blocking.
    ssh ${RESOURCE} ${command} &> /dev/null &
else
    ssh ${RESOURCE} ${command}
fi

# Tell the user how to debug before trying
instruction_get_logs

# Wait for the node allocation, get identifier
get_machine
echo "notebook running on $MACHINE"

[ -z $no_forward ] && setup_port_forwarding

sleep 5
echo 
echo "== Connecting to notebook =="

# Print logs for the user, in case needed
print_logs

echo

instruction_get_logs
echo
i=1
echo "== Instructions =="
echo "$i. Password, output, and error printed to this terminal? Look at logs (see instruction above)" && ((i=i+1))
[ -z $no_forward ] && echo "2. Browser: http://$MACHINE:$PORT/ -> http://localhost:$LOCALPORT/..." && ((i=i+1))
echo "$i. To end session: bash end.sh ${params_file} ${NAME}"
