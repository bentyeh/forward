#!/bin/bash

PORT=$1
NOTEBOOK_DIR=${2:-${HOME}}
ENV=$3
cd $NOTEBOOK_DIR

source ~/.bashrc

# load RStudio (defaults to R version 3.4)
module load rstudio

module load system
module load cairo
module load gcc/9.1.0      # required for Rstudio server

# modules for installing certain packages
# module load fftw           # Cardinal 
# module load libjpeg-turbo  # Cardinal
# module load libtiff        # Cardinal
# module load netcdf         # mzR
# module load zlib           # mzR

conda activate $ENV

rserver --www-address="$(hostname)" --www-port="$PORT" --auth-validate-users=1 --rsession-which-r "$(which R)" --rsession-ld-library-path "~/miniconda3/envs/r/lib"
