USERNAME="btyeh"
LOCALPORT="8889"            # port on local port
PORT="50000"                # port on remote machine
PARTITION="expansion"       # check available partitions: sinfo -a; enter here as comma-separated list
RESOURCE="caltech"
CPU="2"
MEM="100G"
TIME="24:00:00"             # time in hh:mm:ss to request
GPU="0"                     # only used if PARITION="gpu"
EXCLUDE=""                  # don't use GPU nodes in kornberg partition unless necessary
CONSTRAINT=""               # check available features: sinfo -o "%10P %12n %.25f" --sort=P,n | less -S
ENV="py3"                   # conda environment on remote machine
SCRIPT="conda-jupyter"      # sbatch script filename
NAME="conda-jupyter"        # sbatch job name
MAXTIMEOUT=30
MAXATTEMPTS=30
