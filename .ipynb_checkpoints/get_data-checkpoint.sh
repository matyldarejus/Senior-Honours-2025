#!/bin/bash

# ====== Arguments ======
MODEL=$1
WIND=$2
SNAP=$3
GALID=$4
NLOS=$5

# ====== Paths ======
MAKE_SPECTRA=~/sh/make_spectra_sh
ANALYSE_SPECTRA=~/sh/analyse_spectra_sh
SUBMISSION=$MAKE_SPECTRA/submission
PLOTS_DIR=/home/matylda/data/plots

echo "============================================================"
echo "   Gathering and fitting data for for $MODEL $WIND $SNAP"
echo "   Galaxy ID: $GALID "
echo "============================================================"
echo ""

# Step 1: Get galaxy sample
echo "[1/8] Running get_galaxy_sample..."
python $MAKE_SPECTRA/get_galaxy_sample.py $MODEL $WIND $SNAP ||

# Step 2: Get sample temperature
echo "[2/8] Running get_sample_temp..."
python $MAKE_SPECTRA/get_sample_temp.py $MODEL $WIND $SNAP ||
# Step 3: Get galaxy stellar mass & sSFR
echo "[3/8] Running get_gal_sm_ssfr..."
python $MAKE_SPECTRA/get_gal_sm_ssfr.py $MODEL $WIND $SNAP ||

# Step 4: Diagnostic plot
echo "[4/8] Running plot_galaxy_sample (diagnostic)..."
python $MAKE_SPECTRA/plot_galaxy_sample.py $MODEL $WIND $SNAP ||

# Step 5: Save new dataset
echo "[5/8] Running save_new_dataset..."
python $MAKE_SPECTRA/save_new_dataset.py $MODEL $WIND $SNAP ||

# Step 6: Run sub_pipeline for all galaxies
echo "[6/8] Running sub_pipeline.sh (generate spectra)..."
bash $SUBMISSION/sub_pipeline.sh $MODEL $WIND $SNAP $GALID $NLOS ||

# Step 7: Run sub_fit_profiles for all galaxies
echo "[7/8] Running sub_fit_profiles.sh (fit Voigt profiles)..."
bash $SUBMISSION/sub_fit_profiles.sh $MODEL $WIND $SNAP ||

# Step 8: Gather line results
# fr200 values - these may need to be changed depending on the run
FR_VALUES=(0.25 0.5 0.75 1.0 1.25)
for FR in "${FR_VALUES[@]}"; do
    python $ANALYSE_SPECTRA/gather_line_results.py $MODEL $WIND $SNAP $FR $NLOS ||
done


echo "[8/8] Running gather_line_results..."
python $ANALYSE_SPECTRA/gather_line_results.py $MODEL $WIND $SNAP || { echo "gather_line_results failed!"; }

echo ""
echo "============================================================"
echo " Data pipeline completed for $MODEL $WIND $SNAP"
echo "============================================================"