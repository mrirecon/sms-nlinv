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
    # aligned
bart traj -x 384 -y 29 -t 1 -m 2 -l -D -q -0.614225:-0.651670:-0.000881 traja
    # oversampling
bart scale 2 traja traja_os

    # turn-based
bart traj -x 384 -y 29 -t 1 -m 2 -D -q -0.614225:-0.651670:-0.000881 trajt
    # oversampling
bart scale 2 trajt trajt_os

    # golden-angle
bart traj -x 384 -y 29 -t 1 -m 2 -g -D -q -0.614225:-0.651670:-0.000881 trajg
    # oversampling
bart scale 2 trajg trajg_os


###
# Gridding
###
    # nufft needs data in dimensions 1 and 2
bart transpose 1 2 kMB2_aligned_SP29 ka2
bart transpose 0 1 ka2 ka3
bart nufft -d 768:768:1 -a traja_os ka3 nufft_ka
bart fft -u 3 nufft_ka ka_grid

bart transpose 1 2 kMB2_turn_SP29 kt2
bart transpose 0 1 kt2 kt3
bart nufft -d 768:768:1 -a trajt_os kt3 nufft_kt
bart fft -u 3 nufft_kt kt_grid

bart transpose 1 2 kMB2_ga_SP29 kg2
bart transpose 0 1 kg2 kg3
bart nufft -d 768:768:1 -a trajg_os kg3 nufft_kg
bart fft -u 3 nufft_kg kg_grid

###
# PSF
###
    # unit-image
bart ones 16 1 384 29 1 1 1 1 1 1 1 1 1 1 2 1 1 ones

# aligned
    # nufft-gridding
bart nufft -d 768:768:1 -a traja_os ones nuffta
bart fft -u 3 nuffta psfa_tmp
    # scale by inverse number of spokes
bart scale 0.03448275862 psfa_tmp psfa

# turn-based
    # nufft-gridding
bart nufft -d 768:768:1 -a trajt_os ones nufftt
bart fft -u 3 nufftt psft_tmp
    # scale by inverse number of spokes
bart scale 0.03448275862 psft_tmp psft

# golden-angle
    # nufft-gridding
bart nufft -d 768:768:1 -a trajg_os ones nufftg
bart fft -u 3 nufftg psfg_tmp
    # scale by inverse number of spokes
bart scale 0.03448275862 psfg_tmp psfg

###
# SMS-NLINV
###
bart nlinv $NONCART_FLAG -i 10 -p psfa ka_grid reco_a_tmp
bart nlinv $NONCART_FLAG -i 10 -p psft kt_grid reco_t_tmp
bart nlinv $NONCART_FLAG -i 10 -p psfg kg_grid reco_g_tmp
bart resize -c 0 192 1 192 reco_a_tmp MB2_aligned_SP29
bart resize -c 0 192 1 192 reco_t_tmp MB2_turn_SP29
bart resize -c 0 192 1 192 reco_g_tmp MB2_ga_SP29


rm reco*.cfl ka*.cfl kt*.cfl kg*.cfl traj*.cfl *nufft*.cfl ones*.cfl psf*.cfl
rm reco*.hdr ka*.hdr kt*.hdr kg*.hdr traj*.hdr *nufft*.hdr ones*.hdr psf*.hdr

