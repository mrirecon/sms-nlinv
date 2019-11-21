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
bart repmat 0 384 ./Pattern/MB1_ptrn ./Pattern/MB1_pattern

####
# SMS-NLINV
####

# Undersample
bart fmac kMB1_bottom ./Pattern/MB1_pattern k_usamp

## SMS-NLINV reconstruction
bart nlinv -S -i 10 k_usamp rec_MB1_bottom_tmp
bart resize -c 0 192 rec_MB1_bottom_tmp MB1_bottom

## Clean
rm k_*.cfl  rec*.cfl ./Pattern/MB1_pattern*.cfl
rm k_*.hdr  rec*.hdr ./Pattern/MB1_pattern*.hdr
