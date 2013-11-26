#!/bin/bash

GPGPUSIM_DIR=/home/jonathan/gpgpu-sim/v3.x
DATA_DIR="$(dirname $0)/../data"
CUDA_DIR=/opt/cuda-4.0/cuda

# Check that benchmark exists
if [[ ! -d "cuda/$1" ]]
then
   echo "Invalid benchmark: $1"
   exit
fi

benchmark="$1"

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

cd results

if [[ ! -d "$benchmark" ]]
then
   mkdir $benchmark
fi

cd $benchmark

rundir="$platform"_$(date +%F-%H.%M)
mkdir $rundir
cd $rundir

if [[ "$platform" =~ (.*)-sim ]] 
then
   base=${BASH_REMATCH[1]}
   simConfigDir="$GPGPUSIM_DIR/configs/$base"
   cp $simConfigDir/* ./
   ln -s ../../../bin/linux/cuda/"$benchmark"
   ln -s ../../../cuda/"$benchmark"/run

   export CUDA_INSTALL_PATH=$CUDA_DIR
   source $GPGPUSIM_DIR/setup_environment
   ./run > log.txt
fi
