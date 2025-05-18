## Run limits, bias, and goodness-of-fit for a single toy

iToy=$1            ## Toy index
TOYSOURCE=$2       ## Data or MC
MASSES=(15 30 55)  ## Needs to match hard-coded settings in htoaato4b_mctoy.py
NTOYGOF=100        ## Number of toys 2DAlphabet will run for goodness-of-fit test
YEAR="2018"

## Output EOS directory to move ROOT files (avoid disk quota issues)
#EOS_OUT_DIR="/eos/cms/store/user/abrinke1/HiggsToAA/2DAlphabet/ToyStudies/2025_05_15/"
EOS_OUT_DIR="ToyStudies/test/"
echo "Just to be sure, you want to output to:"
echo ${EOS_OUT_DIR}

sToy="toy${iToy}"
## Toy "-1" corresponds to MCrounded or Data
if [ "$iToy" -eq -1 ]; then
    sToy="MCrounded"
    if [[ ${TOYSOURCE} == "Data" ]]; then
	sToy="Data"
    fi
fi

INDIR="mctoysjson"
OUTDIR="${INDIR}/Mergecards_mc${sToy}"
if [[ ${TOYSOURCE} == "Data" ]]; then
    INDIR="datatoysjson"
    OUTDIR="${INDIR}/Mergecards_data${sToy}"
fi

mkdir ${OUTDIR}

# Start the timer
START_TIME=$SECONDS


## WARNING!!! You have to run *all* the "sub-categories" before running the "Comb" categories
#for iCat in LepHi LepLo gg0lHi gg0lLo VBFjjIncl LepComb gg0lComb HadComb LepHadComb; do
for iCat in LepHi LepLo gg0lHi gg0lLo; do

    ## Define WP for each category type
    WP="UNDEF"
    if [[ $iCat == "gg0l"* || $iCat == "VBF"* || $iCat == "Had"* ]]; then
	WP="WP40"
    fi
    if [[ $iCat == "Lep"* && $iCat != "LepHadComb" ]]; then
	WP="WP60"
    fi

    ## Define component sub-categories for each super-category
    subCats=(${iCat})
    subCatsLep=()
    subCatsHad=()
    if [[ $iCat == "LepComb" ]]; then
	subCats=(LepHi LepLo)
    fi
    if [[ $iCat == "gg0lComb" ]]; then
	subCats=(gg0lHi gg0lLo)
    fi
    if [[ $iCat == "HadComb" ]]; then
	subCats=(gg0lHi gg0lLo VBFjjIncl)
    fi
    if [[ $iCat == "LepHadComb" ]]; then
	subCatsHad=(gg0lHi gg0lLo VBFjjIncl)
	subCatsLep=(LepHi LepLo)
    fi

    ## Make toys for each category
    if [[ $iCat != *"Comb" ]]; then
    	echo ">>>>>>>>>> Making Toy #${iToy} in category ${iCat} (${WP})"
    	python3 htoaato4b_mctoy.py "${iToy}" "${iCat}" "${TOYSOURCE}"
    	echo ">>>>>>>>>> Made Toy #${iToy} in category ${iCat} (${WP})"
    fi

    ## Merge datacards and run limits for each mA point
    echo ">>>>>>>>>> Merging datacards for Toy #${iToy} in category ${iCat} (${WP})"
    
    for iMA in "${MASSES[@]}"; do
    	echo "     <<<<< Now looking at mA = ${iMA}"

	in_cards=""
	for jCat in "${subCats[@]}"; do
	    in_cards="${in_cards} ${INDIR}/fits_${jCat}_Htoaato4b_mH_pnet_mA_${MASSES[0]}to${MASSES[-1]}_${WP}_${YEAR}_${sToy}/mA_${iMA}_area/card.txt"
	done
	if [[ $iCat == "LepHadComb" ]]; then
	    in_cards=""
	    for hCat in "${subCatsHad[@]}"; do
		in_cards="${in_cards} ${INDIR}/fits_${hCat}_Htoaato4b_mH_pnet_mA_${MASSES[0]}to${MASSES[-1]}_WP40_${YEAR}_${sToy}/mA_${iMA}_area/card.txt"
	    done
	    for lCat in "${subCatsLep[@]}"; do
		in_cards="${in_cards} ${INDIR}/fits_${lCat}_Htoaato4b_mH_pnet_mA_${MASSES[0]}to${MASSES[-1]}_WP60_${YEAR}_${sToy}/mA_${iMA}_area/card.txt"
	    done
	fi
	echo $in_cards

    	## Combine cards, output to workspace
    	combineCards.py $in_cards > ${OUTDIR}/combined_${iCat}_mA_${iMA}_${YEAR}.txt
    	text2workspace.py ${OUTDIR}/combined_${iCat}_mA_${iMA}_${YEAR}.txt --for-fits --no-wrappers --optimize-simpdf-constraints=cms --X-pack-asympows --use-histsum  --out ${OUTDIR}/workspace_${iCat}_mA_${iMA}_${YEAR}.root

	## Set blinding options
	runOpt="--run=both"
	fitOpt=""
	if [[ ${TOYSOURCE} == "Data" ]]; then
	    runOpt="--run=expected"
	    fitOpt="-t -1"
	fi

    	## AsymptoticLimits
    	combine -M AsymptoticLimits ${OUTDIR}/workspace_${iCat}_mA_${iMA}_${YEAR}.root ${runOpt} --cminDefaultMinimizerStrategy 0 -n .testAsymptoticLimits.mA_${iMA}.${iCat}.${sToy}

    	## FitDiagnostics
    	combine -M FitDiagnostics ${OUTDIR}/workspace_${iCat}_mA_${iMA}_${YEAR}.root ${fitOpt} --setParameters r=0 --cminDefaultMinimizerStrategy 0 --rMin -4 --rMax 4 -n .testFitDiagnostics.mA_${iMA}.${iCat}.${sToy}

    	## GoodnessOfFit
	## Only need to run GoF for one mA point, since signal strength is set to 0
	if [[ $iMA == ${MASSES[0]} ]]; then
    	    combine -M GoodnessOfFit -d ${OUTDIR}/workspace_${iCat}_mA_${iMA}_${YEAR}.root --algo=saturated --fixedSignalStrength 0 -n .testGoodnessOfFit.mA_${iMA}.${iCat}.${sToy} --toysFrequentist -t ${NTOYGOF} -s 123456
	fi
	if [ "$iToy" -ge 0 ]; then
	    echo "mv *.test*.mA_${iMA}.${iCat}.${sToy}*root ${EOS_OUT_DIR}"
	    mv *.test*.mA_${iMA}.${iCat}.${sToy}*root ${EOS_OUT_DIR}
	fi

    	echo "     <<<<< All done with mA = ${iMA}"
    done

    # Calculate elapsed time
    ELAPSED=$((SECONDS - START_TIME))
    hours=$((ELAPSED / 3600))
    minutes=$(((ELAPSED % 3600) / 60))
    seconds=$((ELAPSED % 60))
    echo "Runtime so far: $hours hour(s), $minutes minute(s), $seconds second(s)"

done

echo "TOTAL runtime: $hours hour(s), $minutes minute(s), $seconds second(s)"
