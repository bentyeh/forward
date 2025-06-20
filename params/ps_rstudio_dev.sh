USERNAME="bentyeh"
LOCALPORT="8789"            # port on local port
PORT="49998"                # port on remote machine
PARTITION="dev"             # comma-separated list of normal/bigmem/gpu/dev/owners/kornberg
RESOURCE="sherlock"
CPU="4"
MEM="16G"
TIME="02:00:00"
GPU=""                      # only used if PARITION="gpu"
EXCLUDE="" # sh-115-13"     # don't use GPU nodes in kornberg partition unless necessary
ENV="rpy3"                  # conda environment
SCRIPT="rstudio"            # sbatch script filename
NAME="rstudio-dev"          # sbatch job name
MAXTIMEOUT=30
