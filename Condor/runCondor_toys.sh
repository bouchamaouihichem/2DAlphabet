#!/bin/bash

# Number of Toys
N=5
# Condor log directory
LOG_DIR="Condor_output"

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

# Emptying Condor log directory 
echo " > Make new $LOG_DIR directory .. "
if [ -d "$LOG_DIR" ]; then
   rm -rf "$LOG_DIR"
fi
mkdir "$LOG_DIR"

echo "Deleting .sub/.sh file of previous condor submission"
rm 2D_toys_*

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
done

