#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -n 40
#SBATCH --mail-user=pariksheet.nanda@uconn.edu
#SBATCH --mail-type=END
#SBATCH -o cellprofiler.out

# Clear previous output and add support header.
out=cellprofiler.out
echo "
Job ID = ${SLURM_JOB_ID}
Submission file = ${PWD}/${SLURM_JOB_NAME}
Start datetime = $(date -Isec)
Nodes = ${SLURM_NODELIST}
" > $out

make -f cellprofiler.mk
