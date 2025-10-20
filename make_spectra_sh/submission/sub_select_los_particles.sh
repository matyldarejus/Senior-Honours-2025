#!/bin/bash


pipeline_path=~/sh/make_spectra_sh/select_los_particles.py
model=$1
wind=$2
snap=$3
nlos=8

for i in {0..215}; do
    echo "Running galaxy $i..."
    python $pipeline_path $model $wind $snap $i $nlos
done
