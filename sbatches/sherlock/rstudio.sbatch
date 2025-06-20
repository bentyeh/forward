#!/bin/bash

PORT=$1
NOTEBOOK_DIR=${2:-${HOME}}
cd $NOTEBOOK_DIR

# load RStudio with R 3.6.1
module load rstudio
module load R/3.6.1

# modules for installing certain packages
module load system
module load cairo          # required for png(), etc.
module load gcc/9.1.0      # required for Rstudio server
module load fftw           # required for EBImage

# modules for installing certain packages
module load libjpeg-turbo  # Cardinal
module load libtiff        # Cardinal
module load netcdf         # mzR
module load zlib           # mzR

rserver --www-address="$(hostname)" --www-port="$PORT" --auth-validate-users=1

