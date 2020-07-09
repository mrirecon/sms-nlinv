#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH

NONCART_FLAG=""
if bart version -t v0.6.00 ; then
        NONCART_FLAG="-n"
fi

###
# SMS-NLINV
###

# Traj

bart traj -x 384 -y 39 -t 1 -m 5 -D -g trajt
    # oversampling
bart scale 2 trajt trajt_os


# Gridding
bart transpose 1 2 kSupFig4 kt2 # kspace is the same as for Fig6a
bart transpose 0 1 kt2 kt3
bart nufft -d 768:768:1 -a trajt_os kt3 nufft_kt
bart fft -u 3 nufft_kt kt_grid

# PSF
# turn-based
    # unit-image
bart ones 16 1 384 39 1 1 1 1 1 1 1 1 1 1 5 1 1 ones
    # nufft-gridding
bart nufft -d 768:768:1 -a trajt_os ones nufftt
bart fft -u 3 nufftt psft_tmp
    # scale by inverse number of spokes
bart scale 0.02564102564 psft_tmp psft


# SMS-NLINV
DEBUG_LEVEL=5 bart nlinv $NONCART_FLAG -i 12 -p psft kt_grid reco_t_tmp sens_nlinv > Output.txt

bart resize -c 0 256 1 256 reco_t_tmp tmp_SupFig4_smsnlinv
bart transpose 0 1 tmp_SupFig4_smsnlinv SupFig4_smsnlinv

rm kt*.cfl nufft*cfl ones.cfl psf*.cfl reco*cfl sens*.cfl tmp*.cfl traj*cfl
rm kt*.hdr nufft*hdr ones.hdr psf*.hdr reco*hdr sens*.hdr tmp*.hdr traj*hdr
