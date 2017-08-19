#!/bin/sh

###
# SMS-NLINV
###

# Traj 

bart traj -x 384 -y 39 -t 1 -m 5 -D -g trajt
    # oversampling
bart scale 2 trajt trajt_os


# Gridding
bart transpose 1 2 kFig7 kt2
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
DEBUG_LEVEL=5 bart nlinv -i 11 -p psft kt_grid reco_t_tmp sens_nlinv

bart resize -c 0 256 1 256 reco_t_tmp tmp_Fig7_smsnlinv
bart transpose 0 1 tmp_Fig7_smsnlinv Fig7_smsnlinv

###
# ESPIRiT
###

## Trajectory
bart traj -x 384 -y 39 -t 1 -m 5 -D -g traje

## Gridding
bart nufft -d 384:384:1 -i traje kt3 nufft_ke
bart fft -u 3 nufft_ke ke_grid

## Coil sensitivities
# Disentangle gridded k-space (works only inside of calibration region) and normalize
bart fft -i $(bart bitmask 13) ke_grid tmp2
bart fftshift -b $(bart bitmask 13) tmp2 tmp3
bart scale 0.2 tmp3 ke_grid_dis
# Extract slices
bart slice 13 0 ke_grid_dis ke_grid0
bart slice 13 1 ke_grid_dis ke_grid1
bart slice 13 2 ke_grid_dis ke_grid2
bart slice 13 3 ke_grid_dis ke_grid3
bart slice 13 4 ke_grid_dis ke_grid4
# Estimate coil sensitivities within calibration region
bart ecalib -m1 -r35 ke_grid0 sens0
bart ecalib -m1 -r35 ke_grid1 sens1
bart ecalib -m1 -r35 ke_grid2 sens2
bart ecalib -m1 -r35 ke_grid3 sens3
bart ecalib -m1 -r35 ke_grid4 sens4
bart join 13 sens0 sens1 sens2 sens3 sens4 sens

## ESPIRiT
bart pics -M -t traje -i50 -r0.01 kt3 sens tmp_pics
bart resize -c 0 256 1 256 tmp_pics tmp_Fig7_espirit
bart transpose 0 1 tmp_Fig7_espirit Fig7_espirit


rm reco*.cfl kt*.cfl ke*.cfl traj*.cfl nufft*.cfl sens*.cfl ones.cfl psf*.cfl tmp*.cfl
rm reco*.hdr kt*.hdr ke*.hdr traj*.hdr nufft*.hdr sens*.hdr ones.hdr psf*.hdr tmp*.hdr
