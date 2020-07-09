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
# Gradient delay estimation
#bart transpose 1 2  kMB1_bottom_SP301 tmp
#bart tranpose 0 1 tmp tmp2
#bart estdelay trajf tmp2       # Result: -0.614225:-0.651670:-0.000881

# 301 spokes
bart traj -x 384 -y 301 -t 1 -m 1 -D -q -0.614225:-0.651670:-0.000881 trajF
    # oversampling
bart scale 2 trajF trajF_os

# 29 spokes
bart traj -x 384 -y 29 -t 1 -m 1 -D -q -0.614225:-0.651670:-0.000881 traj
    # oversampling
bart scale 2 traj traj_os

###
# Gridding
###
# 301 spokes
    # nufft needs data in dimensions 1 and 2
bart transpose 1 2 kMB1_bottom_SP301 km2F
bart transpose 0 1 km2F km3F
bart nufft -d 768:768:1 -a trajF_os km3F nufft_kmF
bart fft -u 3 nufft_kmF km_gridF

bart transpose 1 2 kMB1_top_SP301 kp2F
bart transpose 0 1 kp2F kp3F
bart nufft -d 768:768:1 -a trajF_os kp3F nufft_kpF
bart fft -u 3 nufft_kpF kp_gridF

# 29 spokes
bart transpose 1 2 kMB1_bottom_SP29 km2
bart transpose 0 1 km2 km3
bart nufft -d 768:768:1 -a traj_os km3 nufft_km
bart fft -u 3 nufft_km km_grid

bart transpose 1 2 kMB1_top_SP29 kp2
bart transpose 0 1 kp2 kp3
bart nufft -d 768:768:1 -a traj_os kp3 nufft_kp
bart fft -u 3 nufft_kp kp_grid

###
# PSF
###
# 301 spokes
    # unit-image
bart ones 16 1 384 301 1 1 1 1 1 1 1 1 1 1 1 1 1 onesF
    # nufft-gridding
bart nufft -d 768:768:1 -a trajF_os onesF nufftF
bart fft -u 3 nufftF psfF_tmp
    # scale by inverse number of spokes
bart scale 0.00523560209 psfF_tmp psfF

# 29 spokes
    # unit-image
bart ones 16 1 384 29 1 1 1 1 1 1 1 1 1 1 1 1 1 ones
    # nufft-gridding
bart nufft -d 768:768:1 -a traj_os ones nufft
bart fft -u 3 nufft psf_tmp
    # scale by inverse number of spokes
bart scale 0.03448275862 psf_tmp psf

###
# SMS-NLINV
###
# 301 spokes 
bart nlinv -g $NONCART_FLAG -i 10 -p psfF km_gridF reco_m_tmpF
bart nlinv -g $NONCART_FLAG -i 10 -p psfF kp_gridF reco_p_tmpF
bart resize -c 0 192 1 192 reco_m_tmpF MB1_bottom_SP301
bart resize -c 0 192 1 192 reco_p_tmpF MB1_top_SP301

# 29 spokes 
bart nlinv -g $NONCART_FLAG -i 10 -p psf km_grid reco_m_tmp
bart nlinv -g $NONCART_FLAG -i 10 -p psf kp_grid reco_p_tmp
bart resize -c 0 192 1 192 reco_m_tmp MB1_bottom_SP29
bart resize -c 0 192 1 192 reco_p_tmp MB1_top_SP29

rm  traj*.cfl reco_m*.cfl reco_p*.cfl km*.cfl kp*.cfl nufft*.cfl ones*.cfl psf*.cfl
rm  traj*.hdr reco_m*.hdr reco_p*.hdr km*.hdr kp*.hdr nufft*.hdr ones*.hdr psf*.hdr
