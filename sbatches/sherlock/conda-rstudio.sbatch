#!/bin/bash

PORT=$1
NOTEBOOK_DIR=${2:-${HOME}}
ENV=$3
cd $NOTEBOOK_DIR

source ~/.bashrc

# load RStudio (defaults to R version 3.4)
module load rstudio

module load system
module load cairo          # required for png(), etc.
module load gcc/9.1.0      # required for Rstudio server
module load fftw           # required for EBImage

# modules for installing certain packages
module load libjpeg-turbo  # Cardinal
module load libtiff        # Cardinal
module load netcdf         # mzR
module load zlib           # mzR

conda activate $ENV

printenv > ~/curenv.txt

rserver --www-address="$(hostname)" --www-port="$PORT" --auth-validate-users=1 --rsession-ld-library-path "$(realpath -m \"~/miniconda3/envs/$ENV/lib\")"
