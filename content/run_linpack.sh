#!/bin/bash
#location of HPL

HPL_DIR=`pwd`

lrank=$OMPI_COMM_WORLD_LOCAL_RANK

affinity_map=$(nvidia-smi topo -m | awk '/^GPU[0-9]/ {gpus[$NF]+=1; split($(NF-1),cores,"-"); procs[$NF]=cores[2]-cores[1]+1; proc0[$NF]=cores[1]} END {gpu=0; for(socket in gpus){for(i=1; i<=gpus[socket]; i++){print gpu,proc0[socket]+(i-1)*procs[socket]/gpus[socket]"-"proc0[socket]+i*procs[socket]/gpus[socket]-1; gpu+=1}}}')

export CUDA_VISIBLE_DEVICES=${lrank}
PHYS_CPU_BIND=$(echo -e "$affinity_map" | awk '/^'${lrank}' / {print $2}')
export OMP_NUM_THREADS=$(echo $PHYS_CPU_BIND | awk -F'-' '{print $2-$1+1}')

#CPU_CORES_PER_RANK=$OMP_
RANK_PER_NODE=$(nvidia-smi -L | wc -l)
export MKL_NUM_THREADS=$CPU_CORES_PER_RANK
export LD_LIBRARY_PATH=$HPL_DIR:$LD_LIBRARY_PATH

export MONITOR_GPU=1
export GPU_TEMP_WARNING=75
export GPU_CLOCK_WARNING=1230
export GPU_POWER_WARNING=250
export GPU_PCIE_GEN_WARNING=3
export GPU_PCIE_WIDTH_WARNING=16

export TRSM_CUTOFF=1000000
export GPU_DGEMM_SPLIT=1.0

APP=$HPL_DIR/xhpl_cuda-10.0-dyn_mkl-static_ompi-3.1.0_gcc4.8.5_9-26-18

export CUDA_VISIBLE_DEVICES=${lrank}
PHYS_CPU_BIND=$(echo -e "$affinity_map" | awk '/^'${lrank}' / {print $2}')
export OMP_NUM_THREADS=$(echo $PHYS_CPU_BIND | awk -F'-' '{print $2-$1+1}')

numactl --physcpubind=${PHYS_CPU_BIND} $APP
