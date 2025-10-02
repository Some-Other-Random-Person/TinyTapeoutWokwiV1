#!/usr/bin/env bash

# =====================================================
# Author: Simon Dorrer
# Last Modified: 02.10.2025
# Description: This .sh file switches to the SKY130 PDK and runs the LibreLane flow.
# =====================================================

set -e -x

cd $(dirname "$0")

# Switch to sky130A PDK
source sak-pdk-script.sh sky130A sky130_fd_sc_hd > /dev/null

# Run LibreLane
librelane --manual-pdk config.json
