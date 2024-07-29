# Running instructions
```
ssh -X -Y abrinke1@lxplus.cern.ch
cd /afs/cern.ch/work/a/abrinke1/public/HiggsToAA/2DAlphabet/CMSSW_11_3_4/src/
cmssw-cc7
cmsenv
bash
source twoD-env/bin/activate
cd 2DAlphabet/
python3 htoaato4b.py
```

# Installation instructions
```
cmssw-cc7  ## Emulate SLC7 environment; required before any cmsenv
cmsrel CMSSW_11_3_4
cd CMSSW_11_3_4/src
cmsenv
git clone https://github.com/cms-analysis/HiggsAnalysis-CombinedLimit.git HiggsAnalysis/CombinedLimit
cd HiggsAnalysis/CombinedLimit
git fetch origin
git checkout v9.1.0
cd ../../
git clone git@github.com:JHU-Tools/CombineHarvester.git
cd CombineHarvester/
git fetch origin
git checkout CMSSW_11_3_X
cd ../
scramv1 b clean
scramv1 b -j 8

git clone -b py3_AWB_dev git@github.com:abrinke1/2DAlphabet.git
python3 -m virtualenv twoD-env
source twoD-env/bin/activate
cd 2DAlphabet/
python setup.py develop
```

