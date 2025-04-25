#!/bin/bash

#########################################################################
# Updated bash script to run the full MC Toy chain
# Adapted from runtoystudy.sh
#########################################################################

# Start the timer
START_TIME=$SECONDS

# Adjust number of toys
NTOYS='2' #minimum 2

INPUT_DIR='raw_inputs'
OUTPUT_DIR='raw_outputs'

# Emptying the mctoysjson directory 
echo " > Make new mctoysjson directory .. "
if [ -d "mctoysjson" ]; then
   rm -rf "mctoysjson"
fi
mkdir "mctoysjson"

# Emptying the input directory 
echo " > Make new $INPUT_DIR directory .. "
if [ -d "$INPUT_DIR" ]; then
   rm -rf "$INPUT_DIR"
fi
mkdir "$INPUT_DIR"

# Copy all 2D plots
echo " > Copy all input files and preparing inputs.. "
# -- Leptonic --
cp -r /afs/cern.ch/user/h/hboucham/public/2D_Alphabet_Outputs/2D_Limits_040125 raw_inputs/Leptonic_2D_Limits_040125
cp -r /afs/cern.ch/user/h/hboucham/public/2D_Alphabet_Inputs/2D_*030625_mAa raw_inputs/
# -- VBF --
cp -r /afs/cern.ch/user/m/moanwar/public/forYihui/taggerv2_wp40Andwp60 raw_inputs/
cp -r /afs/cern.ch/user/m/moanwar/public/forYihui/2DAlphabetfiles_VBF_inputs plots/
# -- ggH --
cp -r /eos/cms/store/user/ssawant/htoaa/2DAlphabet_datacards/20250403_Pseudodata raw_inputs/

# Prepare inputs
# -- Leptonic --
mkdir -p plots/HtoAA_2DAlphabet_merge_inputs_XXLo/2025_04_04_mAa/
mkdir -p plots/HtoAA_2DAlphabet_merge_inputs_XXHi/2025_04_04_mAa/
### run merge_file_script_mctoy.py to get input files for leptonic channel
python3 merge_file_script_mctoy.py XXHi
python3 merge_file_script_mctoy.py XXLo
### run Haa4b_makeMCtoy.py to make MC sum
python3 Haa4b_makeMCtoy.py Leptonic_Hi
python3 Haa4b_makeMCtoy.py Leptonic_Lo

# -- VBF --
mv plots/2DAlphabetfiles_VBF_inputs/VBFHi_Xto4bv2/VBFjjHi_Xto4bv2_Data_2018.root plots/2DAlphabetfiles_VBF_inputs/VBFHi_Xto4bv2/VBFjjHi_Xto4bv2_MC_2018.root
mv plots/2DAlphabetfiles_VBF_inputs/VBFHi_Xto4bv2/VBFjjHi_Xto4bv2_Data_2018_backup.root plots/2DAlphabetfiles_VBF_inputs/VBFHi_Xto4bv2/VBFjjHi_Xto4bv2_Data_2018.root
mv plots/2DAlphabetfiles_VBF_inputs/VBFLo_Xto4bv2/VBFjjLo_Xto4bv2_Data_2018.root plots/2DAlphabetfiles_VBF_inputs/VBFLo_Xto4bv2/VBFjjLo_Xto4bv2_MC_2018.root
mv plots/2DAlphabetfiles_VBF_inputs/VBFLo_Xto4bv2/VBFjjLo_Xto4bv2_Data_2018_backup.root plots/2DAlphabetfiles_VBF_inputs/VBFLo_Xto4bv2/VBFjjLo_Xto4bv2_Data_2018.root
### run Haa4b_makeMCtoy.py to make MC sum
python3 Haa4b_makeMCtoy.py VBF_Hi
python3 Haa4b_makeMCtoy.py VBF_Lo

# -- ggH --
mkdir -p plots/HtoAA_2DAlphabet_merge_inputs_gg0lIncl/2025_04_04_mAa/
mv raw_inputs/20250403_Pseudodata/2DAlphabet_inputFiles_pseudodata_0/gg0lIncl/gg0lIncl_Data_2018.root raw_inputs/20250403_Pseudodata/2DAlphabet_inputFiles_pseudodata_0/gg0lIncl/gg0lIncl_MC_2018.root
mv raw_inputs/20250403_Pseudodata/2DAlphabet_inputFiles_pseudodata_0/gg0lIncl/gg0lIncl_Data_2018_backup.root raw_inputs/20250403_Pseudodata/2DAlphabet_inputFiles_pseudodata_0/gg0lIncl/gg0lIncl_Data_2018.root
### run merge_file_script_mctoy.py to get input files for ggH Inclusive
python3 merge_file_script_mctoy.py gg0lIncl
### run Haa4b_makeMCtoy.py to make MC sum
python3 Haa4b_makeMCtoy.py gg0lIncl



# Run N toys and make Datacards
echo " > Run N toys and make Datacards .. "

for k in XXHi XXLo VBFjjHi_Xto4bv2 VBFjjLo_Xto4bv2 gg0lIncl; do
  for i in $(seq 0 1 "$NTOYS"); do
    echo ">>>>>>>>>> Making Toy number = $i of channel = $k"
    python3 htoaato4b_mctoy.py "$i" "$k"

    echo ">>>>>>>>>> Moving files for Toy number = $i of channel = $k"
    if [[ "$k" == "XXHi" || "$k" == "XXLo" ]]; then
      mv "fits_${k}_Htoaato4b_mH_pnet_mA_15to55_WP60_2018" \
         "mctoysjson/fits_${k}_Htoaato4b_mH_pnet_mA_15to55_WP60_2018_toy$i"
    elif [[ "$k" == "VBFjjHi_Xto4bv2" || "$k" == "VBFjjLo_Xto4bv2" ]]; then
      mv "fits_${k}_Htoaato4b_mH_pnet_mA_15to55_WP40_2018" \
         "mctoysjson/fits_${k}_Htoaato4b_mH_pnet_mA_15to55_WP40_2018_toy$i"
    elif [[ "$k" == "gg0lIncl" ]]; then
      mv "fits_gg0lIncl_Htoaato4b_mH_pnet_vs_massA34a_mA_15to55_WP40_2018" \
         "mctoysjson/fits_gg0lIncl_Htoaato4b_mH_pnet_vs_massA34a_mA_15to55_WP40_2018_toy$i"
    fi
  done
done

# Combine datacards
echo " > Merging Datacards .. "
source Mergecards.sh "$NTOYS"

# Make summary plots
echo " > Making summary plots .. "
python3 Haa4b_limitsummary.py
python3 Haa4b_fitsummary.py

# Emptying the input directory 
echo " > Make new $OUTPUT_DIR directory .. "
if [ -d "$OUTPUT_DIR" ]; then
   rm -rf "$OUTPUT_DIR"
fi
mkdir "$OUTPUT_DIR"

# Move output files to a single directory
echo " > Moving outputs to raw_outputs/ "
mv *png "$OUTPUT_DIR"
mv higgsCombine.* "$OUTPUT_DIR"
mv fitDiagnostics.* "$OUTPUT_DIR"
mv combine_logger.out "$OUTPUT_DIR"


# Calculate elapsed time 
ELAPSED=$((SECONDS - START_TIME))
hours=$((ELAPSED / 3600))
minutes=$(((ELAPSED % 3600) / 60))
seconds=$((ELAPSED % 60))
echo "Total runtime: $hours hour(s), $minutes minute(s), $seconds second(s)"
