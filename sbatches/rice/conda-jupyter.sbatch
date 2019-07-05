#!/bin/bash
PORT=$1
NOTEBOOK_DIR=${2:-${HOME}}
ENV=$3
cd $NOTEBOOK_DIR

source ~/.bashrc
export XDG_RUNTIME_DIR=''
conda activate $ENV
jupyter notebook --no-browser --ip=0.0.0.0 --port=$PORT
