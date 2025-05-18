## Run single-toy jobs
## Can run up to 10 or so on a single lxplus node, on a few
## nodes at the same time, without the admins getting mad :)
## Would be good to set this up to run on condor / batch

TOYMIN=0
TOYMAX=9
#EOS_OUT_DIR="/eos/cms/store/user/abrinke1/HiggsToAA/2DAlphabet/ToyStudies/2025_05_14/"
EOS_OUT_DIR="ToyStudies/test/"

echo "Just to be sure, you want to output to:"
echo ${EOS_OUT_DIR}

# Set max parallel jobs, otherwise you will run into problems with 100s jobs
MAX_JOBS=100  
job_count=0

# Start the timer
START_TIME=$SECONDS

for iToy in $(seq ${TOYMIN} ${TOYMAX}); do
    echo "./run_toy.sh ${iToy} MC >& ${EOS_OUT_DIR}run_toy_${iToy}_MC.txt &"
    ./run_toy.sh ${iToy} MC >& ${EOS_OUT_DIR}run_toy_${iToy}_MC.txt &
    
    ((job_count++))

    # If max jobs reached, wait for them to finish
    # e.g if you try run 200 jobs, submit 100, waits until they are done,
    # then submits 100 afterwards. Suboptimal, but works.
    if (( job_count >= MAX_JOBS )); then
      wait
      job_count=0
    fi
done
wait

# Calculate elapsed time
ELAPSED=$((SECONDS - START_TIME))
hours=$((ELAPSED / 3600))
minutes=$(((ELAPSED % 3600) / 60))
seconds=$((ELAPSED % 60))
echo "TOTAL runtime for 10 Toys: $hours hour(s), $minutes minute(s), $seconds second(s)"

top
