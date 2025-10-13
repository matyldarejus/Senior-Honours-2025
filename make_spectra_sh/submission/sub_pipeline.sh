#!/bin/bash
#SBATCH --job-name=pygad_spectra
#SBATCH --output=logs/%A_%a.out
#SBATCH --error=logs/%A_%a.err
#SBATCH --array=0-2
#SBATCH --time=24:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=s2315033@ed.ac.uk

module load anaconda
source activate sh_env

pipeline_path=/home/matylda/sh/make_spectra_sh/pipeline.py
model=m25n256
wind=s50
snap=151
line=OVI1031
lambda_rest=1031

echo "Submitting job ${SLURM_ARRAY_TASK_ID}"

python $pipeline_path $model $wind $snap ${SLURM_ARRAY_TASK_ID} $line $lambda_rest

echo "Finished job ${SLURM_ARRAY_TASK_ID}"
