USERNAME="bentyeh"
LOCALPORT="8788"            # port on local port
PORT="50001"                # port on remote machine
PARTITION="kornberg,normal,owners" # comma-separated list of normal/bigmem/gpu/dev/owners/kornberg
RESOURCE="sherlock"
CPU="1"
MEM="16G"
TIME="1-00:00:00"
GPU="0"                     # only used if PARITION="gpu"
EXCLUDE="sh-115-13"         # don't use GPU nodes in kornberg partition unless necessary
ENV="r"                     # conda environment
SCRIPT="conda-rstudio"      # sbatch script filename
NAME="conda-rstudio"        # sbatch job name
MAXTIMEOUT=30
