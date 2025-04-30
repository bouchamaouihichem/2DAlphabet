#!/bin/bash

NTOYS=$1
export mass_points=(15 30 55)
#export mass_points=(30)

for i in "${mass_points[@]}"; do
  for ((it = 0; it < NTOYS; it++)); do

      # Generate Datacards
      export Leptonic_cards="$( ls mctoysjson/fits_XX*_Htoaato4b_mH_pnet_mA_15to55_WP60_2018_toy${it}/mA_${i}_area/card*txt | sed 's/ / /g' | tr '\n' ' ' | sed 's/ $//' )"
      export ggH_cards="$( ls mctoysjson/fits_gg0lIncl_Htoaato4b_mH_pnet_vs_massA34a_mA_15to55_WP40_2018_toy${it}/mA_${i}_area/card*txt | sed 's/ / /g' | tr '\n' ' ' | sed 's/ $//' )"
      export VBF_cards="$( ls mctoysjson/fits_VBFjj*_Xto4bv2_Htoaato4b_mH_pnet_mA_15to55_WP40_2018_toy${it}/mA_${i}_area/card*.txt | sed 's/ / /g' | tr '\n' ' ' | sed 's/ $//' )"
      #echo $Leptonic_cards
      #echo $ggH_cards
      #echo $VBF_cards
      
      # -- ALL --
      combineCards.py $Leptonic_cards $ggH_cards $VBF_cards > mctoysjson/combined_ma_${i}_all.txt
      # -- Leptonic --
      combineCards.py $Leptonic_cards > mctoysjson/combined_ma_${i}_leptonic.txt
      # -- VBF --
      combineCards.py $VBF_cards > mctoysjson/combined_ma_${i}_vbf.txt
      # -- ggH --
      combineCards.py $ggH_cards > mctoysjson/combined_ma_${i}_ggh.txt
    
      # text2workspace.py
      # -- Leptonic --
      text2workspace.py mctoysjson/combined_ma_${i}_leptonic.txt --for-fits --no-wrappers --optimize-simpdf-constraints=cms --X-pack-asympows --use-histsum  --out mctoysjson/workspace_ma_${i}_leptonic.root
      # -- VBF --
      text2workspace.py mctoysjson/combined_ma_${i}_vbf.txt --for-fits --no-wrappers --optimize-simpdf-constraints=cms --X-pack-asympows --use-histsum  --out mctoysjson/workspace_ma_${i}_vbf.root
      # -- ggH --
      text2workspace.py mctoysjson/combined_ma_${i}_ggh.txt --for-fits --no-wrappers --optimize-simpdf-constraints=cms --X-pack-asympows --use-histsum  --out mctoysjson/workspace_ma_${i}_ggh.root
      # -- ALL --
      text2workspace.py mctoysjson/combined_ma_${i}_all.txt --for-fits --no-wrappers --optimize-simpdf-constraints=cms --X-pack-asympows --use-histsum  --out mctoysjson/workspace_ma_${i}_all.root
      
      # AsymptoticLimits and FitDiagnostics
      # -- Leptonic --
      combine -M AsymptoticLimits mctoysjson/workspace_ma_${i}_leptonic.root --cminDefaultMinimizerStrategy 0 -n .testAsymptoticLimits.ma_${i}.leptonic.toy${it}
      combine -M FitDiagnostics mctoysjson/workspace_ma_${i}_leptonic.root --setParameters r=0 --cminDefaultMinimizerStrategy 0 --rMin -40 --rMax 40 -n .testFitDiagnostics.ma_${i}.leptonic.toy${it}
      
      # -- VBF --
      combine -M AsymptoticLimits mctoysjson/workspace_ma_${i}_vbf.root --cminDefaultMinimizerStrategy 0 -n .testAsymptoticLimits.ma_${i}.vbf.toy${it}
      combine -M FitDiagnostics mctoysjson/workspace_ma_${i}_vbf.root --setParameters r=0 --cminDefaultMinimizerStrategy 0 --rMin -40 --rMax 40 -n .testFitDiagnostics.ma_${i}.vbf.toy${it}
      
      # -- ggH --
      combine -M AsymptoticLimits mctoysjson/workspace_ma_${i}_ggh.root --cminDefaultMinimizerStrategy 0 -n .testAsymptoticLimits.ma_${i}.ggh.toy${it}
      combine -M FitDiagnostics mctoysjson/workspace_ma_${i}_ggh.root --setParameters r=0 --cminDefaultMinimizerStrategy 0 --rMin -40 --rMax 40 -n .testFitDiagnostics.ma_${i}.ggh.toy${it}
      
      # -- ALL --
      combine -M AsymptoticLimits mctoysjson/workspace_ma_${i}_all.root --cminDefaultMinimizerStrategy 0 -n .testAsymptoticLimits.ma_${i}.all.toy${it}
      combine -M FitDiagnostics mctoysjson/workspace_ma_${i}_all.root --setParameters r=0 --cminDefaultMinimizerStrategy 0 --rMin -40 --rMax 40 -n .testFitDiagnostics.ma_${i}.all.toy${it}
  done
done 

