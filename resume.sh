#!/bin/bash
#
# Resumes an already running remote sbatch job.
# 
# Usage: bash resume.sh [params_file] [NAME] [--no-forward] [--wait]
# - params_file: path to sbatch job parameters file. default = params.sh
# - NAME: sbatch job name. If not given as an argument, taken from params_file.
# - --no-forward: print job status but do not setup port forwarding
# - --wait: keep checking job status until allocated
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

# Check for "--no-forward" argument and shift arguments $1, $2, ... accordingly
# - https://stackoverflow.com/questions/255898/how-to-iterate-over-arguments-in-a-bash-script
# - https://stackoverflow.com/questions/4827690/how-to-change-a-command-line-argument-in-bash
# argc=$#
# argv=($@)
# for ((i=0; i<argc; i++)); do
#     if [[ "${argv[$i]}" = "--no-forward" ]]; then
#         no_forward="true"
#         if [[ $i -eq 0 ]]; then
#             set -- "${@:$(($i+2)):$argc}"
#         else
#             set -- "${@:1:$(($i))}" "${@:$(($i+2)):$argc}"
#         fi
#         break
#     fi
# done

# Argument parsing: see https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
PARAMS=""
while (( "$#" )); do
  case "$1" in
    --no-forward)
      no_forward=true;         shift 1;;
    --wait)
      wait=true;               shift 1;;
    --) # end argument parsing
      shift
      break
      ;;
    -*) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

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

echo "Looking up existing job: ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o \"%i %T %L %C %m %P %N\" -h"
RESULT=`ssh ${RESOURCE} squeue --name=$NAME --user=$USERNAME -o \"%i %T %L %C %m %P %N\" -h`
read JOBID STATE TIME_LEFT CPUS MEM PARTITION MACHINE <<< "$RESULT"
if [[ -z $JOBID ]]; then
    echo "No job with name $NAME and user $USERNAME on $RESOURCE found."
elif [[ -z $MACHINE ]]; then
    if [ "$wait" = true ]; then
        source helpers.sh
        get_machine
        echo "Job running on $MACHINE"

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
    else
        echo "No nodes currently allocated."
        echo "Job ID: $JOBID. Job state: $STATE. Time remaining: $TIME_LEFT." \
             "CPUs: $CPUS. Memory: $MEM. Partition(s): $PARTITION"
    fi
else
    echo "Job ID: $JOBID. Job state: $STATE. Time remaining: $TIME_LEFT." \
         "CPUs: $CPUS. Memory: $MEM. Partition: $PARTITION. Nodelist: $MACHINE."
    if [[ -z $no_forward ]]; then
        echo "Resuming port forwarding: ssh -N -L localhost:$LOCALPORT:$MACHINE:$PORT $RESOURCE &"
        ssh -N -L localhost:$LOCALPORT:$MACHINE:$PORT $RESOURCE &
    fi
fi