#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH


####
# Pattern
####
bart repmat 0 384 ./Pattern/MB3_ptrn_caipi ./Pattern/MB3_pattern_caipi

####
# SMS-NLINV
####

# Undersample
bart fmac kMB3 ./Pattern/MB3_pattern_caipi k_usamp

## SMS-NLINV reconstruction
bart nlinv -S -i 10 k_usamp rec_MB3_CAI_tmp
bart resize -c 0 192 rec_MB3_CAI_tmp MB3_caipi

# Clean
rm *tmp*.cfl k_*.cfl ./Pattern/MB3_pattern*.cfl
rm *tmp*.hdr k_*.hdr ./Pattern/MB3_pattern*.hdr


## REMARK
# The intermediate slice was located in the transition region of the brick-phantom, 
# i.e. we observe a partial volume effect
