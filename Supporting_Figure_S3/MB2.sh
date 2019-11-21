#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH


###
# Trajectory
###
# 69 spokes
    # aligned
bart traj -x 384 -y 69 -t 1 -m 2 -l -D -q -0.614225:-0.651670:-0.000881 trajaM
    # oversampling
bart scale 2 trajaM trajaM_os

    # turn-based
bart traj -x 384 -y 69 -t 1 -m 2 -D -q -0.614225:-0.651670:-0.000881 trajtM
    # oversampling
bart scale 2 trajtM trajtM_os

    # golden-angle
bart traj -x 384 -y 69 -t 1 -m 2 -g -D -q -0.614225:-0.651670:-0.000881 trajgM
    # oversampling
bart scale 2 trajgM trajgM_os


###
# Gridding
###
# 69 spokes
    # nufft needs data in dimensions 1 and 2
bart transpose 1 2 kMB2_aligned_SP69 ka2M
bart transpose 0 1 ka2M ka3M
bart nufft -d 768:768:1 -a trajaM_os ka3M nufft_kaM
bart fft -u 3 nufft_kaM kaM_grid

bart transpose 1 2 kMB2_turn_SP69 kt2M
bart transpose 0 1 kt2M kt3M
bart nufft -d 768:768:1 -a trajtM_os kt3M nufft_ktM
bart fft -u 3 nufft_ktM ktM_grid

bart transpose 1 2 kMB2_ga_SP69 kg2M
bart transpose 0 1 kg2M kg3M
bart nufft -d 768:768:1 -a trajgM_os kg3M nufft_kgM
bart fft -u 3 nufft_kgM kgM_grid


###
# PSF
###
# 69 spokes
    # unit-image
bart ones 16 1 384 69 1 1 1 1 1 1 1 1 1 1 2 1 1 onesM

# aligned
    # nufft-gridding
bart nufft -d 768:768:1 -a trajaM_os onesM nufftaM
bart fft -u 3 nufftaM psfaM_tmp
    # scale by inverse number of spokes
bart scale 0.01449275362 psfaM_tmp psfaM

# turn-based
    # nufft-gridding
bart nufft -d 768:768:1 -a trajtM_os onesM nuffttM
bart fft -u 3 nuffttM psftM_tmp
    # scale by inverse number of spokes
bart scale 0.01449275362 psftM_tmp psftM

# golden-angle
    # nufft-gridding
bart nufft -d 768:768:1 -a trajgM_os onesM nufftgM
bart fft -u 3 nufftgM psfgM_tmp
    # scale by inverse number of spokes
bart scale 0.01449275362 psfgM_tmp psfgM


###
# SMS-NLINV
###
# 69 spokes
bart nlinv -i 10 -p psfaM kaM_grid reco_aM_tmp
bart nlinv -i 10 -p psftM ktM_grid reco_tM_tmp
bart nlinv -i 10 -p psfgM kgM_grid reco_gM_tmp
bart resize -c 0 192 1 192 reco_aM_tmp MB2_aligned_SP69
bart resize -c 0 192 1 192 reco_tM_tmp MB2_turn_SP69
bart resize -c 0 192 1 192 reco_gM_tmp MB2_ga_SP69


rm reco*.cfl ka*.cfl kt*.cfl kg*.cfl traj*.cfl *nufft*.cfl ones*.cfl psf*.cfl
rm reco*.hdr ka*.hdr kt*.hdr kg*.hdr traj*.hdr *nufft*.hdr ones*.hdr psf*.hdr

