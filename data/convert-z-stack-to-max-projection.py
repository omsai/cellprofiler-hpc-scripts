import glob
import multiprocessing as mp
import os

import numpy as np
import scipy.misc


out_dir = 'z_stack'
z_slices = 3
# Assume all files are tif, and therefore that the number of files is
# a multiple of z_slices.
print("Reading file list")
all_files = glob.glob('April_14_2016/*/*')
all_files.sort()

if not os.path.exists(out_dir):
    print("Creating output directory")
    os.mkdir(out_dir)

print("Creating output file list")
all_files_out = [
    os.path.join(out_dir,
                 os.path.basename(all_files[i].replace("_Z1", "")))
    for i in xrange(0, len(all_files), z_slices)
]

def max_projection(pool_index):
    offset = pool_index * z_slices
    im1 = scipy.misc.imread(all_files[offset])
    shape = [1] + list(im1.shape)
    for file_ in all_files[offset + 1:offset + z_slices]:
        im2 = scipy.misc.imread(file_)
        im_stack = np.concatenate((im1.reshape(shape),
                                   im2.reshape(shape)), axis=0)
        im1 = im_stack.max(axis=0)
    scipy.misc.imsave(all_files_out[pool_index], im1)

print("Reading images, merging and saving (this can take a while)")
pool = mp.Pool(4)
#pool.map(max_projection, range(16))
pool.map(max_projection, xrange(len(all_files_out)))

print("Finished")
