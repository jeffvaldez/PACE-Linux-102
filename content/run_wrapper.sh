#!/bin/bash
#location of HPL

cd $PBS_O_WORKDIR

HPL_DIR=`pwd`

awk -F. '{slots[$1]+=1} END {for(host in slots) print host" slots="slots[host]}' $PBS_GPUFILE > hosts

module load openmpi cuda/10.0 &>/dev/null

TEST_NAME=pace-gpu
DATETIME=`hostname`.`date +"%m%d.%H%M%S"`
mkdir ./results/HPL-$TEST_NAME-results-$DATETIME
echo "Results in folder ./results/HPL-$TEST_NAME-results-$DATETIME"
RESULT_FILE=./results/HPL-$TEST_NAME-results-$DATETIME/HPL-$TEST_NAME-results-$DATETIME-out.txt

mpirun -np $(wc -l <${PBS_GPUFILE}) -bind-to none --hostfile hosts -x LD_LIBRARY_PATH ./run_linpack 2>&1 | tee $RESULT_FILE

echo "RESULTS in $RESULT_FILE" >> ./results/result_summary.txt
grep "WC\|WR" $RESULT_FILE >> ./results/result_summary.txt
grep "WC\|WR" $RESULT_FILE
