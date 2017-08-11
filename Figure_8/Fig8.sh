#!/bin/sh

# Gradient delay corrected trajectory
bart traj -x 320 -y 7 -t 5 -m 2 -D 1 -q 0:0.5:0  traj_tmp
    # oversampling
bart scale 2 traj_tmp traj_os
    # join time-dimension of trajectory
for i in 0 1 2 3 4 
do
    bart slice 10 $i traj_os traj$i
done
bart join 2 traj0 traj1 traj2 traj3 traj4 traj

# k-space gridding
bart transpose 1 2 kFig8 k_static2
bart transpose 0 1 k_static2 k_static3
bart nufft -d 640:640:1 -a traj k_static3 nufft_k
bart fft -u 3 nufft_k k_grid

# PSF
# turn-based
    # unit-image
bart ones 16 1 320 35 1 1 1 1 1 1 1 1 1 1 2 1 1 ones
    # nufft-gridding
bart nufft -d 640:640:1 -a traj ones nufft
bart fft -u 3 nufft psf_tmp
    # scale by inverse number of spokes
bart scale 0.02857142857 psf_tmp psf


# SMS-NLINV
bart nlinv -H1 -f0.5 -n1 -i13 -p psf k_grid reco_tmp
bart resize -c 0 160 1 160 reco_tmp Fig8

# Tidy up
rm reco*.cfl k_*.cfl traj*.cfl nufft*.cfl ones.cfl ps*.cfl
rm reco*.hdr k_*.hdr traj*.hdr nufft*.hdr ones.hdr ps*.hdr
