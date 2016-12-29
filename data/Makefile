z_stack.tar.xz : z_stack
	source /etc/profile.d/modules.sh ; \
	module load xz ; \
	XZ_DEFAULTS="-T 0" tar -cI xz -f $@ $<

z_stack.tar.bz2 : z_stack
	tar -cI pbzip2 -f $@ $<

z_stack/ : April_14_2016/
	python convert-z-stack-to-max-projection.py

April_14_2016/ : April_14_2016.tar.xz
	tar -xJpf $<