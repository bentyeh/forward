USERNAME="bentyeh"
LOCALPORT="8889"            # port on local port
PORT="50000"                # port on remote machine
PARTITION="dev" # comma-separated list of normal/bigmem/gpu/dev/owners/kornberg
RESOURCE="sherlock"
CPU="4"                     # maximum 4 CPUs on dev partition
MEM="16G"
TIME="2:00:00"              # maximum 2:00:00 on dev partition
GPU="0"                      # only used if PARITION="gpu"
EXCLUDE="" # sh-115-13"         # don't use GPU nodes in kornberg partition unless necessary
ENV="rpy3"                   # conda environment
SCRIPT="conda-jupyter"      # sbatch script filename
NAME="conda-jupyter-dev"        # sbatch job name
MAXTIMEOUT=30
MAXATTEMPTS=30
