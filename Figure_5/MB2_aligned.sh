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
bart repmat 0 384 ./Pattern/MB2_ptrn_aligned ./Pattern/MB2_pattern_aligned

####
# SMS-NLINV
####

# Undersample
bart fmac kMB2 ./Pattern/MB2_pattern_aligned k_usamp

## SMS-NLINV reconstruction
bart nlinv -S -i 10 k_usamp rec_MB2_Ali_tmp
bart resize -c 0 192 rec_MB2_Ali_tmp MB2_aligned

## Clean
rm *tmp*.cfl k_*.cfl ./Pattern/MB2_pattern*.cfl
rm *tmp*.hdr k_*.hdr ./Pattern/MB2_pattern*.hdr
