#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.4.03"


####
# Pattern
####
bart repmat 0 384 ./Pattern/MB2_ptrn_caipi ./Pattern/MB2_pattern_caipi

####
# SMS-NLINV
####

# Undersample
bart fmac kMB2 ./Pattern/MB2_pattern_caipi k_usamp

## SMS-NLINV reconstruction
bart nlinv -S -i 10 k_usamp rec_MB2_CAI_tmp
bart resize -c 0 192 rec_MB2_CAI_tmp MB2_caipi

## Clean
rm *tmp*.cfl k_*.cfl ./Pattern/MB2_pattern*.cfl
rm *tmp*.hdr k_*.hdr ./Pattern/MB2_pattern*.hdr
