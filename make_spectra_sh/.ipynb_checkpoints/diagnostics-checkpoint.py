import caesar
import yt
import numpy as np
import h5py
import sys

model = sys.argv[1]
wind = sys.argv[2]
snap = sys.argv[3]

sample_dir = f'/disk04/mrejus/sh/samples/'
sample_file = f'{sample_dir}{model}_{wind}_{snap}_galaxy_sample.h5'

with h5py.File(sample_file, 'r') as f:
        gal_ids = f['gal_ids'][:]


# Check the number of galaxies in the sample

print(f'Number of galaxies in the sample: {len(gal_ids)}')

