#!/bin/bash

pipeline_path=/home/matylda/sh/make_spectra_sh/fit_profiles.py
model=m25n256
wind=s50
snap=151

for i in {0..215}; do
    echo "Running galaxy $i..."
    python $pipeline_path $model $wind $snap $i
done
