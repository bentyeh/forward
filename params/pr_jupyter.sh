USERNAME="bentyeh"
LOCALPORT="8889"            # port on local port
PORT="50000"                # port on remote machine
PARTITION="normal"          # comma-separated list of normal/bigmem/gpu
QOS="interactive"           # long/interactive/dev/normal/gpu/bigmem
RESOURCE="rice"
CPU="1"
MEM="32G"
TIME="02:00:00"
GPU="0"                     # only used if PARITION="gpu"
EXCLUDE=""
ENV="py3"                   # conda environment
SCRIPT="conda-jupyter"      # sbatch script filename
NAME="conda-jupyter"        # sbatch job name
MAXTIMEOUT=30
MAXATTEMPTS=30
