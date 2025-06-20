USERNAME="bentyeh"
LOCALPORT="8889"            # port on local port
PORT="50000"                # port on remote machine
PARTITION="kornberg,owners" # comma-separated list of normal/bigmem/gpu/dev/owners/kornberg
RESOURCE="sherlock"
CPU="12"                    # maximum 4 CPUs on dev partition
MEM="64G"
TIME="8:00:00"              # maximum 2:00:00 on dev partition
GPU="0"                     # only used if PARITION="gpu"
EXCLUDE="" # sh-115-13"     # don't use GPU nodes in kornberg partition unless necessary
CONSTRAINT="NO_GPU"
ENV="rpy3"                  # conda environment
SCRIPT="conda-jupyter"      # sbatch script filename
NAME="conda-jupyter"        # sbatch job name
MAXTIMEOUT=30
MAXATTEMPTS=30
