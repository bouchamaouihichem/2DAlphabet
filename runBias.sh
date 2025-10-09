#!/bin/bash

# First set: Run2 categories
datasets=("Data" "MC")
flags=(0 1)
categories1=("LepHiT" "LepLo" "HadXHi" "HadXLo")
runs1=("Run2")

echo "=== Running first set (Run2 categories) ==="
for d in "${datasets[@]}"; do
  for f in "${flags[@]}"; do
    for c in "${categories1[@]}"; do
      for r in "${runs1[@]}"; do
        echo "Running: python3 macros/Haa4b_BiasmA_summary.py $d $f $c $r"
        python3 macros/Haa4b_BiasmA_summary.py "$d" "$f" "$c" "$r"
      done
    done
  done
done

# Second set: gg0lV categories with multiple years
categories2=("gg0lVHi" "gg0lVLo")
runs2=("2018" "2017" "2016")

echo "=== Running second set (gg0lV categories) ==="
for d in "${datasets[@]}"; do
  for f in "${flags[@]}"; do
    for c in "${categories2[@]}"; do
      for r in "${runs2[@]}"; do
        echo "Running: python3 macros/Haa4b_BiasmA_summary.py $d $f $c $r"
        python3 macros/Haa4b_BiasmA_summary.py "$d" "$f" "$c" "$r"
      done
    done
  done
done

# copy plots
cp /afs/cern.ch/work/h/hboucham/Haa4b/2D_Alphabet_toys/CMSSW_11_3_4/src/2DAlphabet/figures/MultiDimFit/2025_08_15/Run2/bias_vs_mA_* /eos/user/h/hboucham/www_hichem/Haa4b_plots/plot_view/2D_Bias/083125
cp /afs/cern.ch/work/h/hboucham/Haa4b/2D_Alphabet_toys/CMSSW_11_3_4/src/2DAlphabet/figures/MultiDimFit/2025_08_15/2018/bias_vs_mA_gg0lV* /eos/user/h/hboucham/www_hichem/Haa4b_plots/plot_view/2D_Bias/083125
cp /afs/cern.ch/work/h/hboucham/Haa4b/2D_Alphabet_toys/CMSSW_11_3_4/src/2DAlphabet/figures/MultiDimFit/2025_08_15/2017/bias_vs_mA_gg0lV* /eos/user/h/hboucham/www_hichem/Haa4b_plots/plot_view/2D_Bias/083125
cp /afs/cern.ch/work/h/hboucham/Haa4b/2D_Alphabet_toys/CMSSW_11_3_4/src/2DAlphabet/figures/MultiDimFit/2025_08_15/2016/bias_vs_mA_gg0lV* /eos/user/h/hboucham/www_hichem/Haa4b_plots/plot_view/2D_Bias/083125
