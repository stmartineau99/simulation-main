#!/bin/bash
#SBATCH -p large96s
#SBATCH --job-name=polnet_sn_array
#SBATCH --array=0-2
#SBATCH -o /projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/data/simulation/slurm_logs/slurm-%A_%a.out
#SBATCH -t 12:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
 
CONFIG=$1
source ~/.bashrc
micromamba activate -n simulation-main

SCRIPT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/source/polnet-synaptic/scripts/data_gen
cd $SCRIPT_DIR

python all_features_synapse.py \
  --config $CONFIG