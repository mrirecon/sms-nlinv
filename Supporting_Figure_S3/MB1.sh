#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.4.03"

NONCART_FLAG=""
if bart version -t v0.6.00 ; then
        NONCART_FLAG="-n"
fi

###
# Trajectory
###

# 69 spokes
bart traj -x 384 -y 69 -t 1 -m 1 -D -q -0.614225:-0.651670:-0.000881 trajM
    # oversampling
bart scale 2 trajM trajM_os

###
# Gridding
###
# 69 spokes
    # nufft needs data in dimensions 1 and 2
bart transpose 1 2 kMB1_bottom_SP69 km2M
bart transpose 0 1 km2M km3M
bart nufft -d 768:768:1 -a trajM_os km3M nufft_kmM
bart fft -u 3 nufft_kmM km_gridM

bart transpose 1 2 kMB1_top_SP69 kp2M
bart transpose 0 1 kp2M kp3M
bart nufft -d 768:768:1 -a trajM_os kp3M nufft_kpM
bart fft -u 3 nufft_kpM kp_gridM


###
# PSF
###
# 69 spokes
    # unit-image
bart ones 16 1 384 69 1 1 1 1 1 1 1 1 1 1 1 1 1 onesM
    # nufft-gridding
bart nufft -d 768:768:1 -a trajM_os onesM nufftM
bart fft -u 3 nufftM psfM_tmp
    # scale by inverse number of spokes
bart scale 0.01449275362 psfM_tmp psfM

###
# SMS-NLINV
###

# 69 spokes 
bart nlinv $NONCART_FLAG -i 10 -p psfM km_gridM reco_m_tmpM
bart nlinv $NONCART_FLAG -i 10 -p psfM kp_gridM reco_p_tmpM
bart resize -c 0 192 1 192 reco_m_tmpM MB1_bottom_SP69
bart resize -c 0 192 1 192 reco_p_tmpM MB1_top_SP69

rm  traj*.cfl reco_m*.cfl reco_p*.cfl km*.cfl kp*.cfl nufft*.cfl ones*.cfl psf*.cfl
rm  traj*.hdr reco_m*.hdr reco_p*.hdr km*.hdr kp*.hdr nufft*.hdr ones*.hdr psf*.hdr
