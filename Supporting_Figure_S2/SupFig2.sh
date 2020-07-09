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
# Trajectory
###
# 301 spokes
    # linear-turn
bart traj -x 384 -y 301 -t 1 -m 3 -D -q -0.614225:-0.651670:-0.000881 trajtM
    # oversampling
bart scale 2 trajtM trajtM_os

# 29 spokes
    # linear-turn
bart traj -x 384 -y 29 -t 1 -m 3 -D -q -0.614225:-0.651670:-0.000881 trajt
    # oversampling
bart scale 2 trajt trajt_os


###
# Gridding
###
# 301 spokes
bart transpose 1 2 kMB3_turn_SP301 kt2M
bart transpose 0 1 kt2M kt3M
bart nufft -d 768:768:1 -a trajtM_os kt3M nufft_ktM
bart fft -u 3 nufft_ktM ktM_grid

# 29 spokes
bart transpose 1 2 kMB3_turn_SP29 kt2
bart transpose 0 1 kt2 kt3
bart nufft -d 768:768:1 -a trajt_os kt3 nufft_kt
bart fft -u 3 nufft_kt kt_grid

###
# PSF
###
# 301 spokes
    # unit-image
bart ones 16 1 384 301 1 1 1 1 1 1 1 1 1 1 3 1 1 onesM
# turn-based
    # nufft-gridding
bart nufft -d 768:768:1 -a trajtM_os onesM nuffttM
bart fft -u 3 nuffttM psftM_tmp
    # scale by inverse number of spokes
bart scale 0.00332225913 psftM_tmp psftM

# 29 spokes
    # unit-image
bart ones 16 1 384 29 1 1 1 1 1 1 1 1 1 1 3 1 1 ones
# turn-based
    # nufft-gridding
bart nufft -d 768:768:1 -a trajt_os ones nufftt
bart fft -u 3 nufftt psft_tmp
    # scale by inverse number of spokes
bart scale 0.03448275862 psft_tmp psft


###
# SMS-NLINV
###
# 301 spokes
bart nlinv $NONCART_FLAG -S -i 10 -p psftM ktM_grid reco_tM_tmp
bart resize -c 0 192 1 192 reco_tM_tmp tmp_MB3_turn_SP301

# 29 spokes
bart nlinv $NONCART_FLAG -S -i 10 -p psft kt_grid reco_t_tmp
bart resize -c 0 192 1 192 reco_t_tmp MB3_turn_SP29

###
# Difference images in image & k-space 
###
# Scale reconstructions to same energy
scale=$(bart nrmse -s tmp_MB3_turn_SP301 MB3_turn_SP29 | awk 'NR==1 {print $0}' | sed 's/Scaled by: //')
bart scale $scale tmp_MB3_turn_SP301 MB3_turn_SP301
# Image space
bart saxpy -- -1 MB3_turn_SP301 MB3_turn_SP29 tmp_im_diff
bart scale 5 tmp_im_diff im_diff
# k-space
bart fft 3 MB3_turn_SP301 k_recoMB3_turn_SP301
bart fft 3 MB3_turn_SP29 k_recoMB3_turn_SP29
bart saxpy -- -1 k_recoMB3_turn_SP301 k_recoMB3_turn_SP29 tmp_k_diff
bart scale 1 tmp_k_diff k_diff

# Join 
bart join 4 MB3_turn_SP301 MB3_turn_SP29 im_diff im_recoMB3
bart join 4 k_recoMB3_turn_SP301 k_recoMB3_turn_SP29 k_diff k_recoMB3

rm reco*.cfl kt*.cfl traj*.cfl nufft*.cfl ones*.cfl psf*.cfl tmp*.cfl im_diff.cfl k_diff.cfl MB3_*.cfl k_recoMB3_*.cfl
rm reco*.hdr kt*.hdr traj*.hdr nufft*.hdr ones*.hdr psf*.hdr tmp*.hdr im_diff.hdr k_diff.hdr MB3_*.hdr k_recoMB3_*.hdr

