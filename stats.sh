#!/bin/bash

benchmark=$1
platform=$2

matches=$(find results/$benchmark/$platform* -type d)

select resultsDir in $matches
do
   break;
done

statFile=$(mktemp)

if [[ "$resultsDir" == *-sim* ]]
then
   grep gpu_tot_sim_cycle $resultsDir/log.txt | tail -n1
else
   nvprof --import-profile $resultsDir/profile.out --log-file %1 >> $statFile
   nvprof --import-profile $resultsDir/events.out --log-file %1 >> $statFile
   nvprof --import-profile $resultsDir/metrics.out --log-file %1 >> $statFile
fi

less $statFile

rm $statFile
