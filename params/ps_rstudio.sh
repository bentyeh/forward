USERNAME="bentyeh"
LOCALPORT="8789"            # port on local port
PORT="49999"                # port on remote machine
PARTITION="kornberg,owners" # comma-separated list of normal/bigmem/gpu/dev/owners/kornberg
RESOURCE="sherlock"
CPU="16"
MEM="100G"
TIME="12:00:00"
GPU=""                      # only used if PARITION="gpu"
EXCLUDE="" # sh-115-13"     # don't use GPU nodes in kornberg partition unless necessary
CONSTRAINT="NO_GPU"
ENV="rpy3"                  # conda environment
SCRIPT="rstudio"            # sbatch script filename
NAME="rstudio"              # sbatch job name
MAXTIMEOUT=30
