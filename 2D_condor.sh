#!/bin/bash

# Number of Toys
N=10

# Template files
SH_TEMPLATE="2D_toys.sh"
SUB_TEMPLATE="2D_toys.sub"


# Check if both templates exist
if [[ ! -f $SH_TEMPLATE ]]; then
  echo "Error: $SH_TEMPLATE not found!"
  exit 1
fi

if [[ ! -f $SUB_TEMPLATE ]]; then
  echo "Error: $SUB_TEMPLATE not found!"
  exit 1
fi
# Emptying the mctoysjson directory 
echo " > Make Condor directory .. "
if [ -d "Condor_dir" ]; then
   rm -rf "Condor_dir"
fi
mkdir "Condor_dir"

# Loop over N toy jobs
for ((i=0; i<N; i++)); do
  SH_OUT="2D_toys_${i}.sh"
  SUB_OUT="2D_toys_${i}.sub"

  # Create .sh file, replacing NTOY with the index
  sed "s/NTOY/${i}/g" "$SH_TEMPLATE" > "$SH_OUT"
  chmod +x "$SH_OUT"

  # Create .sub file, replacing reference to original .sh with the modified .sh name
  sed "s/2D_toys.sh/${SH_OUT}/g" "$SUB_TEMPLATE" > "$SUB_OUT"

  echo "Created $SH_OUT and $SUB_OUT"
  
  echo "Submitting jobs for Toy ${i}"
  condor_submit 2D_toys_${i}.sub
  
  echo "Deleting all condor .sh and .sub files after submission"
  rm $SH_OUT
  rm $SUB_OUT
done
