#!/bin/bash
## Modified from https://raw.githubusercontent.com/bouchamaouihichem/2DAlphabet/refs/heads/dev25_0501/runToys.sh

#########################################################################
# Updated bash script to run the full MC Toy chain
# Adapted from runtoystudy.sh by Hichem B
#########################################################################

# Start the timer
START_TIME=$SECONDS

# Adjust number of toys
NTOYS='2500' # Minimum of 2. 2500 takes about 15 minutes.

# # Are using 2D Alphabet output? (Option not enabled - AWB 2025.05.16)
# WORKSPACE='2Dworkspace' # YES
# #WORKSPACE='No2Dworkspace' # NO

# Do you want to generate toys from MC or Data or both?
#TOYSOURCE='MC'
#TOYSOURCE='Data'
TOYSOURCE='DataAndMC'

INPUT_DIR='raw_inputs'
OUTPUT_DIR='raw_outputs'


# Emptying the mctoysjson and datatoysjson directories
if [[ "${TOYSOURCE}" == "MC" || "${TOYSOURCE}" == "DataAndMC" ]]
then
    echo " > Make new mctoysjson directory .. "
    if [ -d "mctoysjson" ]; then
	rm -rf "mctoysjson"
    fi
    mkdir "mctoysjson"
fi
if [[ "${TOYSOURCE}" == "Data" || "${TOYSOURCE}" == "DataAndMC" ]]
then
    echo " > Make new datatoysjson directory .. "
    if [ -d "datatoysjson" ]; then
	rm -rf "datatoysjson"
    fi
    mkdir "datatoysjson"
fi


# Emptying the input directory 
echo " > Make new $INPUT_DIR directory .. "
if [ -d "$INPUT_DIR" ]; then
   rm -rf "$INPUT_DIR"
fi
mkdir "$INPUT_DIR"


# Copy all 2D plots
echo " > Copy all input 2D histogram files .. "
# -- ggH --
cp -r /eos/cms/store/user/ssawant/htoaa/analysis/20250502_gg0l_FullSyst/2018/2DAlphabet_inputFiles_pseudodata raw_inputs/2D_in_gg0l_2025_05_02
# -- VBF --
mkdir raw_inputs/2D_in_VBFjj_2025_04_06
cp -r /afs/cern.ch/user/m/moanwar/public/forYihui/2DAlphabetfiles_VBF_inputs/VBFLo_Xto4bv2 raw_inputs/2D_in_VBFjj_2025_04_06/VBFjjLo
cp -r /afs/cern.ch/user/m/moanwar/public/forYihui/2DAlphabetfiles_VBF_inputs/VBFHi_Xto4bv2 raw_inputs/2D_in_VBFjj_2025_04_06/VBFjjHi
# -- Leptonic --
cp -r /afs/cern.ch/user/h/hboucham/public/2D_Alphabet_Inputs/2D_2LZ_030625_mAa raw_inputs/2D_in_Zll_2025_03_06
cp -r /afs/cern.ch/user/h/hboucham/public/2D_Alphabet_Inputs/2D_2Ltt_030625_mAa raw_inputs/2D_in_ttll_2025_03_06
cp -r /afs/cern.ch/user/h/hboucham/public/2D_Alphabet_Inputs/2D_1L_030625_mAa raw_inputs/2D_in_Wlv_ttlv_2025_03_06

# Rename some files
echo " > Rename some confusingly named files ('Data' really means 'MC'!) .. "
for iCat in gg0lLo gg0lHi gg0lIncl;
do
    mv raw_inputs/2D_in_gg0l_2025_05_02/${iCat}/${iCat}_Data_2018.root raw_inputs/2D_in_gg0l_2025_05_02/${iCat}/${iCat}_MC_2018.root
    mv raw_inputs/2D_in_gg0l_2025_05_02/${iCat}/${iCat}_Data_2018_backup.root raw_inputs/2D_in_gg0l_2025_05_02/${iCat}/${iCat}_Data_2018.root
done
for jCat in Lo Hi;
do
    mv raw_inputs/2D_in_VBFjj_2025_04_06/VBFjj${jCat}/VBFjj${jCat}_Xto4bv2_Data_2018.root raw_inputs/2D_in_VBFjj_2025_04_06/VBFjj${jCat}/VBFjj${jCat}_Xto4bv2_MC_2018.root
    mv raw_inputs/2D_in_VBFjj_2025_04_06/VBFjj${jCat}/VBFjj${jCat}_Xto4bv2_Data_2018_backup.root raw_inputs/2D_in_VBFjj_2025_04_06/VBFjj${jCat}/VBFjj${jCat}_Xto4bv2_Data_2018.root
done

if [[ "${WORKSPACE}" == "2Dworkspace" ]]
then
    echo " > Copy all 2DAlphabet output workspace files .. "
    # -- ggH --
    cp -r /eos/cms/store/user/ssawant/htoaa/analysis/20250502_gg0l_FullSyst/2018/2DAlphabet_fits_pseudodata raw_inputs/2D_out_gg0l_2025_05_07
    # -- VBF --
    cp -r /afs/cern.ch/user/m/moanwar/public/forYihui/taggerv2_wp40Andwp60 raw_inputs/2D_out_VBFjj_2025_03_12
    # -- Leptonic --
    cp -r /afs/cern.ch/user/h/hboucham/public/2D_Alphabet_Outputs/2D_Limits_040125 raw_inputs/2D_out_Lep_2025_04_01
fi


# Prepare inputs
echo " > Merging categories (LepHi, LepLo, gg0lIncl, VBFjjIncl)"
python3 merge_file_script_mctoy.py LepHi
python3 merge_file_script_mctoy.py LepLo
python3 merge_file_script_mctoy.py gg0lIncl
python3 merge_file_script_mctoy.py VBFjjIncl


# Throw the toys!
echo " > Making toys for LepHi categories .. "
python3 Haa4b_makeMCtoy.py LepHi $NTOYS $TOYSOURCE
echo " > Making toys for LepLo categories .. "
python3 Haa4b_makeMCtoy.py LepLo $NTOYS $TOYSOURCE
echo " > Making toys for gg0lIncl categories .. "
python3 Haa4b_makeMCtoy.py gg0lIncl $NTOYS $TOYSOURCE
echo " > Making toys for gg0lHi categories .. "
python3 Haa4b_makeMCtoy.py gg0lHi $NTOYS $TOYSOURCE
echo " > Making toys for gg0lLo categories .. "
python3 Haa4b_makeMCtoy.py gg0lLo $NTOYS $TOYSOURCE
echo " > Making toys for VBFjjIncl categories .. "
python3 Haa4b_makeMCtoy.py VBFjjIncl $NTOYS $TOYSOURCE


# Calculate elapsed time 
ELAPSED=$((SECONDS - START_TIME))
hours=$((ELAPSED / 3600))
minutes=$(((ELAPSED % 3600) / 60))
seconds=$((ELAPSED % 60))
echo "Total runtime: $hours hour(s), $minutes minute(s), $seconds second(s)"
