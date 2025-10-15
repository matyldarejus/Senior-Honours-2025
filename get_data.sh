#!/bin/bash

# Usage: bash run_full_pipeline.sh MODEL WIND SNAP GALID NLOS

# ====== Parse arguments ======
MODEL=$1
WIND=$2
SNAP=$3
GALID=$4
NLOS=$5

# ====== Paths ======
MAKE_SPECTRA=~/sh/make_spectra_sh
ANALYSE_SPECTRA=~/sh/analyse_spectra_sh
SUBMISSION=$MAKE_SPECTRA/submission
PLOTS_DIR=/home/matylda/plots

echo "============================================================"
echo "   RUNNING FULL PIPELINE for $MODEL $WIND $SNAP"
echo "   Galaxy ID: $GALID | NLOS: $NLOS"
echo "============================================================"
echo ""

# Step 1: Get galaxy sample
echo "[1/8] Running get_galaxy_sample..."
python $MAKE_SPECTRA/get_galaxy_sample.py $MODEL $WIND $SNAP || { echo "get_galaxy_sample failed / already exists"; }

# Step 2: Get sample temperature
echo "[2/8] Running get_sample_temp..."
python $MAKE_SPECTRA/get_sample_temp.py $MODEL $WIND $SNAP || { echo "get_sample_temp failed! / already exists"; }

# Step 3: Get galaxy stellar mass & sSFR
echo "[3/8] Running get_gal_sm_ssfr..."
python $MAKE_SPECTRA/get_gal_sm_ssfr.py $MODEL $WIND $SNAP || { echo "get_gal_sm_ssfr failed! / already exists"; }

# Step 4: Diagnostic plot
echo "[4/8] Running plot_galaxy_sample (diagnostic)..."
python $MAKE_SPECTRA/plot_galaxy_sample.py $MODEL $WIND $SNAP || echo "plot_galaxy_sample failed (non-fatal)."
echo "   Plot produced: ${PLOTS_DIR}/${MODEL}_${WIND}_${SNAP}_Tcgm_new.png"

# Step 5: Save new dataset
echo "[5/8] Running save_new_dataset..."
python $MAKE_SPECTRA/save_new_dataset.py $MODEL $WIND $SNAP || { echo "save_new_dataset failed!"; }

# Step 6: Run sub_pipeline for all galaxies
echo "[6/8] Running sub_pipeline.sh (generate spectra)..."
bash $SUBMISSION/sub_pipeline.sh $MODEL $WIND $SNAP $GALID $NLOS || { echo "sub_pipeline.sh failed!"; }

# Step 7: Run sub_fit_profiles for all galaxies
echo "[7/8] Running sub_fit_profiles.sh (fit Voigt profiles)..."
bash $SUBMISSION/sub_fit_profiles.sh $MODEL $WIND $SNAP || { echo "sub_fit_profiles.sh failed!"; }

# Step 8: Gather line results
# Define the same fr200 range used in your scripts
DELTA_FR200=0.25
MIN_FR200=0.25
NBINS_FR200=5
# fr200 values
FR_VALUES=(0.25 0.5 0.75 1.0 1.25)
for FR in "${FR_VALUES[@]}"; do
    echo "   → Running gather_line_results for ${FR}r200..."
    python $ANALYSE_SPECTRA/gather_line_results.py $MODEL $WIND $SNAP $FR || {
        echo "gather_line_results failed for ${FR}r200!"
    }
done


echo "[8/8] Running gather_line_results (final data collation)..."
python $ANALYSE_SPECTRA/gather_line_results.py $MODEL $WIND $SNAP || { echo "gather_line_results failed!"; }

echo ""
echo "============================================================"
echo " Pipeline completed successfully for $MODEL $WIND $SNAP"
echo "============================================================"