#!/bin/bash
#SBATCH -p debug
$SBATCH -N 1
#SBATCH -n 4

source /etc/profile.d/modules.sh
module purge
module load python/2.7.6

time make
