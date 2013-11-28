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
DATA_DIR="$RODINIA_DIR/data/$benchmark"
input=${3:-"small"}

# Check for valid platforms
platforms=(hw GTX480-sim QuadroFX5600-sim QuadroFX5800-sim TeslaC2050-sim)
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

if [[ "$platform" == "hw" ]]
then
   # Get the name of the GPU 0 reported by nvidia-smi
   # nvidia-smi isn't tested on anything other than my own system, so I don't
   # know if it reports all cards and what format it may use for them
   platform=$(nvidia-smi -L | cut -d' ' -f4,5 --output-delimiter='' | tr '[:upper:]' '[:lower:]')
   echo "Found hw: $platform"
fi

rundir="$platform"_"$input"_$(date +%F-%H.%M)
mkdir -p "results/$benchmark/$rundir"
cd "results/$benchmark/$rundir"

source "$RODINIA_DIR/cuda/$benchmark/run.conf"
runCmd="$RODINIA_DIR/bin/linux/cuda/$runExec $runArgs"

echo "Run directory: $RODINIA_DIR/results/$benchmark/$rundir"
echo "$runCmd"
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
   nvprof --log-file %1 $runCmd >> log.txt
fi

echo "Finished"
