## Run single-toy jobs
## Can run up to 10 or so on a single lxplus node, on a few
## nodes at the same time, without the admins getting mad :)
## Would be good to set this up to run on condor / batch

TOYMIN=0
TOYMAX=9
EOS_OUT_DIR="/eos/cms/store/user/abrinke1/HiggsToAA/2DAlphabet/ToyStudies/2025_05_14/"

echo "Just to be sure, you want to output to:"
echo ${EOS_OUT_DIR}

for iToy in $(seq ${TOYMIN} ${TOYMAX}); do
    echo "./run_toy.sh ${iToy} MC >& ${EOS_OUT_DIR}run_toy_${iToy}_MC.txt &"
    ./run_toy.sh ${iToy} MC >& ${EOS_OUT_DIR}run_toy_${iToy}_MC.txt &
done
top
