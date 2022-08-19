#!/bin/bash
set -e

if [ ! -e $TOOLBOX_PATH/bart ] ; then
	echo "\$TOOLBOX_PATH is not set correctly!" >&2
	exit 1
fi
export PATH=$TOOLBOX_PATH:$PATH
export BART_COMPAT_VERSION="v0.4.03"


####
# Pattern
####
bart repmat 0 384 Fig4a_ptrn Fig4a_pattern

####
# ESPIRiT
# The pics reconstruction needs the slices in dimension 2
####

# Retrospective undersampling
bart fmac k Fig4a_pattern k_usamp

## Coil sensitivities
#Disentangle slices and normalize
bart fft -i 4 k k_ifft
bart scale 0.5 k_ifft k_ifftN

# Full k-space
# Extract the slices
bart slice 2 0 k_ifftN k_ifftN_0
bart slice 2 1 k_ifftN k_ifftN_1
# Calibration
bart ecalib -m1 k_ifftN_0 sens_full_0
bart ecalib -m1 k_ifftN_1 sens_full_1
bart join 2 sens_full_0 sens_full_1 sens_full

# Reduced k-space
# Undersample k-space
bart fmac k_ifftN Fig4a_pattern k_ifftN_usamp 
# Extract the slices
bart slice 2 0 k_ifftN_usamp k_ifftN_usamp_0
bart slice 2 1 k_ifftN_usamp k_ifftN_usamp_1
# Calibration
bart ecalib -m1 k_ifftN_usamp_0 sens_usamp_0
bart ecalib -m1 k_ifftN_usamp_1 sens_usamp_1
bart join 2 sens_usamp_0 sens_usamp_1 sens_usamp


## L2-ESPIRiT reconstruction
bart pics -S -e -l2 -r0.01 k sens_full rec_ESPIRiT_full
bart pics -S -e -l2 -r0.01 k_usamp sens_usamp rec_ESPIRiT_usamp
bart resize -c 0 192 rec_ESPIRiT_usamp rec_ESPIRiT_usamp_resize
 
## Difference image
# Multiply image with sensitivities
bart fmac rec_ESPIRiT_usamp sens_usamp rec_ESPIRiT_usamp_sens
bart fmac rec_ESPIRiT_full sens_full rec_ESPIRiT_full_sens
# RSS coil combination
bart rss 8 rec_ESPIRiT_usamp_sens rec_ESPIRiT_usamp_sens_rss
bart rss 8 rec_ESPIRiT_full_sens rec_ESPIRiT_full_sens_rss
# Subtract 
bart saxpy -- -1 rec_ESPIRiT_usamp_sens_rss rec_ESPIRiT_full_sens_rss diff_ESPIRiT
# Scale for better visibility & Resize
bart scale 5 diff_ESPIRiT diff_ESPIRiTx5
bart resize -c 0 192 diff_ESPIRiTx5 diff_ESPIRiTx5_resize
# Absolute value output
bart rss 32 diff_ESPIRiTx5_resize diff_ESPIRiTx5_resize_out # necessary to avoid viewer-issues
# Join into one file
bart join 4 rec_ESPIRiT_usamp_resize diff_ESPIRiTx5_resize_out ESPIRiT_tmp
# Slice ordering
bart flip 4 ESPIRiT_tmp ESPIRiT_4a


####
# SMS-NLINV
# The SMS-NLINV reconstruction needs the slices in the dimension 13
####

# Full k-space
bart transpose 2 13 k k_NLINV

# Undersampled k-space
bart transpose 2 13 k_usamp k_usamp_NLINV

## SMS-NLINV reconstruction
bart nlinv -S -i 9 k_NLINV rec_SMSNLINV_full
bart nlinv -S -i 9 k_usamp_NLINV rec_SMSNLINV_usamp
bart resize -c 0 192 rec_SMSNLINV_usamp rec_SMSNLINV_usamp_resize

## Difference image
# Get magnitude image
bart rss 32 rec_SMSNLINV_full rec_SMSNLINV_full_rss
bart rss 32 rec_SMSNLINV_usamp rec_SMSNLINV_usamp_rss
# Subtract
bart saxpy -- -1 rec_SMSNLINV_usamp_rss rec_SMSNLINV_full_rss diff_SMSNLINV
# Scale for better visibility & Resize
bart scale 5 diff_SMSNLINV diff_SMSNLINVx5 # scale for better visibility
bart resize -c 0 192 diff_SMSNLINVx5 diff_SMSNLINVx5_resize
# Absolute value output
bart rss 32 diff_SMSNLINVx5_resize diff_SMSNLINVx5_resize_out
# Join into one file
bart join 4 rec_SMSNLINV_usamp_resize diff_SMSNLINVx5_resize_out SMSNLINV_4a

rm diff*.cfl k_*.cfl rec*.cfl sens*.cfl Fig4a_pattern*.cfl ESPIRiT_tmp.cfl
rm diff*.hdr k_*.hdr rec*.hdr sens*.hdr Fig4a_pattern*.hdr ESPIRiT_tmp.hdr
