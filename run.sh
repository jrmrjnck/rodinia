#!/bin/bash

GPGPUSIM_DIR="/home/jonathan/gpgpu-sim/v3.x"
RODINIA_DIR="/home/jonathan/rodinia"
CUDA_DIR="/opt/cuda-4.2/cuda"

# Check that benchmark exists
if [[ ! -d "cuda/$1" ]]
then
   echo "Invalid benchmark: $1"
   exit
fi

benchmark="$1"
input="$3"
source "cuda/$benchmark/run.conf"
runCmd="$RODINIA_DIR/bin/linux/cuda/$runExec $runArgs"

# Check for valid platforms
platforms=(gt240 gtx460m gtx760 GTX480-sim QuadroFX5600-sim QuadroFX5800-sim TeslaC2050-sim)
platform=''

for p in "${platforms[@]}"
do
   if [[ "$p" == "$2" ]]
   then
      platform=$p
   fi
done

if [[ -z "$platform" ]]
then
   echo "Invalid platform: $2"
   echo "Options are: ${platforms[@]}"
   exit
fi

_input=$input
rundir="$platform"_$(date +%F-%H.%M)
mkdir -p "results/$benchmark/$rundir"
cd "results/$benchmark/$rundir"

# Make sure data symlink is in place for the run script
if [[ ! -L ../../data ]]
then
   ln -s ../../data ../../data
fi

echo -e "$runCmd\n$input\n" > log.txt

if [[ "$platform" =~ (.*)-sim ]] 
then
   # Set up the run directory
   base=${BASH_REMATCH[1]}
   simConfigDir="$GPGPUSIM_DIR/configs/$base"
   cp $simConfigDir/* ./

   # Run in gpgpu-sim
   export CUDA_INSTALL_PATH=$CUDA_DIR
   source $GPGPUSIM_DIR/setup_environment
   eval $runCmd >> log.txt
else
   gpus=$(nvidia-smi -L | sed -e 's/ //g' | tr '[:upper:]' '[:lower:]')
   if [[ "$gpus" != *"$platform"* ]]
   then
      echo "$platform not found"
      cd ..
      rmdir $rundir
      exit
   fi

   export LD_LIBRARY_PATH="$CUDA_DIR/lib64"
   nvprof "$runCmd" >> log.txt
fi
