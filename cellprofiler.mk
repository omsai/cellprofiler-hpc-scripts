# Run CellProfiler on the Storrs HPC cluster https://hpc.uconn.edu
#
# The trouble with installing CellProfiler as a module on the cluster
# is the use of system graphical libraries (wx) even for running in
# headless mode.  Therefore we use a singularity container to bundle
# the necessary libraries.  The singularity build definition is
# available here:
# https://gist.github.com/omsai/a6394fc38c9224f681bd732c4836611f

SHARE = /scratch/scratch3
SCRATCH = /work
SHARE_PREFIX = $(SHARE)/$(USER)
SCRATCH_PREFIX = $(SCRATCH)/$(USER)
IN_TARBALL = $(SHARE_PREFIX)/data/z_stack.tar.xz
IN_PIPELINE = $(SHARE_PREFIX)/pipeline.cpproj
IN_DIR = $(SCRATCH_PREFIX)/z_stack
IN_FILELIST = $(SCRATCH_PREFIX)/filelist
OUT_DIR = $(SCRATCH_PREFIX)/cellprofiler_all-plates
CELLPROFILER_SINGULARITY_IMAGE = $(SHARE_PREFIX)/centos7-cellprofiler-2.2.0.img
CELLPROFILER_DONE_FILE = $(SCRATCH_PREFIX)/status
OUT_TARBALL = $(OUT_DIR).tar.xz
UPLOAD_TARBALL = $(SHARE_PREFIX)/$(lastword $(subst /, ,$(OUR_TARBALL)))

define module_load
source /etc/profile.d/modules.sh; module load $(1);
endef

# xz version 5.2.2 with multi-threading for speed.
define load_xz_module
$(call module_load,xz)
endef

define load_singularity_module
$(call module_load,singularity)
endef

define cellprofiler
$(load_singularity_module) \
singularity run \
-B $(SHARE):$(SHARE) \
-B $(SCRATCH):$(SCRATCH) \
$(CELLPROFILER_SINGULARITY_IMAGE)
endef

$(UPLOAD_TARBALL) : $(OUT_TARBALL)
	cp -arv $< $@

$(OUT_TARBALL) : $(CELLPROFILER_DONE_FILE)
	cd $(@D); $(load_xz_module) time tar -I xz -cf $(@F) $(notdir $(OUR_DIR))

# No error exit code from cellprofiler even on failure; therefore use
# --done-file instead.
.PHONY : run-cellprofiler
run-cellprofiler : $(CELLPROFILER_DONE_FILE)
$(CELLPROFILER_DONE_FILE) : $(IN_FILELIST)
	$(cellprofiler) \
	--run-headless \
	--run \
	--pipeline=$(IN_PIPELINE) \
	--output-directory=$(dir $(CELLPROFILER_DONE_FILE)) \
	--file-list=$(IN_FILELIST) \
	--done-file=$@
	grep Failure $@ || rm $@

# Interactive
.PHONY: cellprofiler
cellprofiler : $(IN_FILELIST)
	$(cellprofiler) \
	--pipeline=$(IN_PIPELINE) \
	--output-directory=$(dir $(CELLPROFILER_DONE_FILE)) \
	--file-list=$(IN_FILELIST)

.PHONY : unpack
unpack : $(IN_FILELIST)
$(IN_FILELIST) : $(IN_DIR)
	find $< -type f | sort > $@

$(IN_DIR) : $(IN_TARBALL)
	mkdir -p $(@D)
	cd $(@D); $(load_xz_module) time tar -I xz -xf $<
	touch -r $< $@
