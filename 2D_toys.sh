#!/bin/bash

cd /afs/cern.ch/work/h/hboucham/Haa4b/2D_Alphabet_toys/CMSSW_11_3_4/src/
cmsenv
source twoD-env/bin/activate
cd 2DAlphabet
bash run_toy.sh 9 MC
