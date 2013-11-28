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

# Make sure data symlink is in place for the run script
if [[ ! -L ../../data ]]
then
   ln -s ../../data ../../data
fi

if [[ "$platform" =~ (.*)-sim ]] 
then
   # Set up the run directory
   base=${BASH_REMATCH[1]}
   simConfigDir="$GPGPUSIM_DIR/configs/$base"
   cp $simConfigDir/* ./
   ln -s ../../../bin/linux/cuda/"$benchmark"
   ln -s ../../../cuda/"$benchmark"/run

   # Run in gpgpu-sim
   export CUDA_INSTALL_PATH=$CUDA_DIR
   source $GPGPUSIM_DIR/setup_environment
   cat run > log.txt
   echo -e "\n\n" >> log.txt
   ./run >> log.txt
else
   gpus=$(nvidia-smi -L | sed -e 's/ //g' | tr '[:upper:]' '[:lower:]')
   if [[ "$gpus" != *"$platform"* ]]
   then
      echo "$platform not found"
      cd ..
      rmdir $rundir
      exit
   fi

   ln -s ../../../bin/linux/cuda/"$benchmark"
   ln -s ../../../cuda/"$benchmark"/run
   export LD_LIBRARY_PATH="$CUDA_DIR/lib64"
   cat run > log.txt
   echo -e "\n\n" >> log.txt
   nvprof ./run >> log.txt
fi
