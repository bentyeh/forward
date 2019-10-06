USERNAME="bentyeh"
LOCALPORT="8788"            # port on local port
PORT="50000"                # port on remote machine
PARTITION="owners,kornberg" # comma-separated list of normal/bigmem/gpu/dev/owners/kornberg
RESOURCE="sherlock"
CPU="2"
MEM="40G"
TIME="04:00:00"
GPU="0"                     # only used if PARITION="gpu"
EXCLUDE="" # sh-115-13"         # don't use GPU nodes in kornberg partition unless necessary
ENV="rpy3"                  # conda environment
SCRIPT="conda-rstudio"      # sbatch script filename
NAME="conda-rstudio"        # sbatch job name
MAXTIMEOUT=30
