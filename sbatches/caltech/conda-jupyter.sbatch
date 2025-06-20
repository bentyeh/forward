#!/bin/bash

PORT=$1
NOTEBOOK_DIR=${2:-${HOME}}
ENV=$3
cd $NOTEBOOK_DIR

source ~/.bashrc
conda activate $ENV
jupyter lab --no-browser --ip=0.0.0.0 --port=$PORT
