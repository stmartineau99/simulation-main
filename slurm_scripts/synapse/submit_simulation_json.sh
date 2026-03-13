#!/bin/bash
SCRIPT1=./slurm_scripts/synapse/sbatch_polnet_synapse_array.sh
SCRIPT2=./slurm_scripts/synapse/sbatch_faket_synapse.sh

PARENT_DIR=/projects/extern/nhr/nhr_ni/nim00020/dir.project/sage/data/simulation/testing/run6
CONFIG_DIR=$PARENT_DIR/configs
JSON_DIR=$PARENT_DIR/slurm_metrics
mkdir -p $JSON_DIR

for CONFIG in $CONFIG_DIR/*.toml; do
    CONFIG_NAME=$(basename $CONFIG .toml)
    SCRIPT1_JOB_NAME="polnet_${CONFIG_NAME}"
    SCRIPT2_JOB_NAME="faket_${CONFIG_NAME}"

    SCRIPT1_JOB_ID=$(sbatch --job-name=$SCRIPT1_JOB_NAME $SCRIPT1 $CONFIG | awk '{print $4}')
    echo "Submitted $SCRIPT1_JOB_NAME as job $SCRIPT1_JOB_ID"

    SCRIPT2_JOB_ID=$(sbatch --job-name=$SCRIPT2_JOB_NAME --dependency=afterok:$SCRIPT1_JOB_ID $SCRIPT2 $CONFIG | awk '{print $4}')
    echo "Submitted $SCRIPT2_JOB_NAME as job $SCRIPT2_JOB_ID"

    SCRIPT1_JSON="${JSON_DIR}/slurm_${SCRIPT1_JOB_ID}_${SCRIPT1_JOB_NAME}.json"
    SCRIPT2_JSON="${JSON_DIR}/slurm_${SCRIPT2_JOB_ID}_${SCRIPT2_JOB_NAME}.json"

    sbatch --dependency=afterok:$SCRIPT1_JOB_ID \
           --job-name="${SCRIPT1_JOB_NAME}_metrics" \
           --wrap="python ./slurm_scripts/collect_slurm_metrics.py $SCRIPT1_JOB_ID $SCRIPT1_JSON --is_array"

    sbatch --dependency=afterok:$SCRIPT2_JOB_ID \
           --job-name="${SCRIPT2_JOB_NAME}_metrics" \
           --wrap="python ./slurm_scripts/collect_slurm_metrics.py $SCRIPT2_JOB_ID $SCRIPT2_JSON"
done
