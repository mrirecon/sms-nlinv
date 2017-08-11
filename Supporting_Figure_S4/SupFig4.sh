#!/bin/sh
set -e

###
# SMS-NLINV
###

# Traj 

bart traj -x 384 -y 39 -t 1 -m 5 -D1 -g trajt
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
DEBUG_LEVEL=5 bart nlinv -H1 -f0.5 -i 12 -n1 -p psft kt_grid reco_t_tmp sens_nlinv > Output.txt

bart resize -c 0 256 1 256 reco_t_tmp tmp_SupFig4_smsnlinv
bart transpose 0 1 tmp_SupFig4_smsnlinv SupFig4_smsnlinv
 

# Plot Residual
sed -n '/Res:/p' Output.txt | sed 's/Step://' | awk '{$l; print $0}' | sed 's/, Res:/\t/' > SupportingFigureS4.txt # Extract Step and Residuum
# Plot using Python 2.7
python plot.py -x "Newton step" -y "Residuum [a.u.]" -g -d "0 1" --xlim "-0.5 11.5" -e "eps" --ms 10  SupportingFigureS4.txt SupportingFigureS4

rm kt*.cfl nufft*cfl ones.cfl psf*.cfl reco*cfl sens*.cfl tmp*.cfl traj*cfl
rm kt*.hdr nufft*hdr ones.hdr psf*.hdr reco*hdr sens*.hdr tmp*.hdr traj*hdr