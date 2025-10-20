#!/bin/bash

pipeline_path=~/sh/make_spectra_sh/pipeline.py
model=$1
wind=$2
snap=$3
line=H1215
lambda_rest=1215

for i in {0..104}; do
    echo "Running galaxy $i..."
    python $pipeline_path $model $wind $snap $i $line $lambda_rest
done
