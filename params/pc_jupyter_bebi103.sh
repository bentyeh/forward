USERNAME="btyeh"
LOCALPORT="8890"            # port on local port
PORT="50001"                # port on remote machine
PARTITION="any"             # check available partitions: sinfo -a; enter here as comma-separated list
RESOURCE="caltech"
CPU="4"
MEM="20G"
TIME="12:00:00"             # time in hh:mm:ss to request
GPU="0"                     # only used if PARITION="gpu"
EXCLUDE=""                  # don't use GPU nodes in kornberg partition unless necessary
CONSTRAINT=""               # check available features: sinfo -o "%10P %12n %.25f" --sort=P,n | less -S
ENV="bebi103"               # conda environment on remote machine
SCRIPT="conda-jupyter"      # sbatch script filename
NAME="conda-jupyter"        # sbatch job name
MAXTIMEOUT=30
MAXATTEMPTS=30
