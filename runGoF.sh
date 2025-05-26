#!/bin/bash

#########################################################################
# Script to make GoF plots for all categories and mass points
# by Hichem.B
#########################################################################

# Start the timer
START_TIME=$SECONDS

# Adjust number of toys used in GoF
NTOYSGOF='500'

# The toy you want to use for GoF
iTOY='2' 

# output directory
OUTPUT_DIR='GoF_files'

# Emptying the output directory 
echo " > Make new $OUTPUT_DIR directory .. "
if [ -d "$OUTPUT_DIR" ]; then
   rm -rf "$OUTPUT_DIR"
fi
mkdir "$OUTPUT_DIR"

# Running GoF for all mass points and categories
for i in 15 30 55; do
  for iCat in LepHi LepLo gg0lHi gg0lLo; do
    combine -M GoodnessOfFit mctoysjson/Mergecards_mctoy${iTOY}/workspace_${iCat}_mA_${i}_2018.root --algo saturated -m 125 --freezeParameters MH -n .goodnessOfFit.mA_${i}.${iCat}
    combine -M GoodnessOfFit mctoysjson/Mergecards_mctoy${iTOY}/workspace_${iCat}_mA_${i}_2018.root --algo saturated -m 125 --freezeParameters MH -n .goodnessOfFit.mA_${i}.${iCat} -t $NTOYSGOF
  done
done

mv higgsCombine.goodnessOfFit* ${OUTPUT_DIR}

# Making GoF plots
#python3 Haa4b_gofsummary.py

# Calculate elapsed time 
ELAPSED=$((SECONDS - START_TIME))
hours=$((ELAPSED / 3600))
minutes=$(((ELAPSED % 3600) / 60))
seconds=$((ELAPSED % 60))
echo "Total runtime: $hours hour(s), $minutes minute(s), $seconds second(s)"
