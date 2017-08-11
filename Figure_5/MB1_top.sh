#!/bin/sh
set -e
####
# Pattern
####
bart repmat 0 384 ./Pattern/MB1_ptrn ./Pattern/MB1_pattern

####
# SMS-NLINV
####

# Undersample
bart fmac kMB1_top ./Pattern/MB1_pattern k_usamp

## SMS-NLINV reconstruction
bart nlinv -H1 -S -i 10 -n1 k_usamp rec_MB1_top_tmp
bart resize -c 0 192 rec_MB1_top_tmp MB1_top

## Clean
rm k_*.cfl rec*.cfl ./Pattern/MB1_pattern*.cfl
rm k_*.hdr rec*.hdr ./Pattern/MB1_pattern*.hdr