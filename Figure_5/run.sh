#!/bin/bash

set -e

./MB1_bottom.sh
./MB1_top.sh

./MB2_aligned.sh
./MB2_caipi.sh

./MB3_aligned.sh
./MB3_caipi.sh
