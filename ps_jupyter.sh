USERNAME="bentyeh"
LOCALPORT="8889"            # port on local port
PORT="50000"                # port on remote machine
PARTITION="kornberg,normal,owners" # comma-separated list of normal/bigmem/gpu/dev/owners/kornberg
RESOURCE="sherlock"
CPU="1"
MEM="16G"
TIME="1-00:00:00"
GPU="0"                     # only used if PARITION="gpu"
EXCLUDE="sh-115-13"         # don't use GPU nodes in kornberg partition unless necessary
ENV="py3"                   # conda environment
SCRIPT="conda-jupyter"      # sbatch script filename
NAME="conda-jupyter"        # sbatch job name
MAXTIMEOUT=30
