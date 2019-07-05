USERNAME="bentyeh"
LOCALPORT="8889"            # port on local port
PORT="50000"                # port on remote machine
PARTITION="normal"          # comma-separated list of normal/bigmem/gpu
RESOURCE="rice"
CPU="1"
MEM="16G"
TIME="1-00:00:00"
GPU="0"                     # only used if PARITION="gpu"
EXCLUDE=""
ENV="py3"                   # conda environment
SCRIPT="conda-jupyter"      # sbatch script filename
NAME="conda-jupyter"        # sbatch job name
MAXTIMEOUT=30
