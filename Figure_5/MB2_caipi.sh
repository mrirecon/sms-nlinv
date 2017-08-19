#!/bin/sh
set -e
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
