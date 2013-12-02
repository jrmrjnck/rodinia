#!/bin/bash

benchmarks=(backprop bfs b+tree cfd gaussian heartwall hotspot kmeans lavaMD lud mummergpu myocyte nn nw particlefilter pathfinder srad streamcluster)
platforms=(hw GTX480-sim QuadroFX5600-sim QuadroFX5800-sim TeslaC2050-sim)

cmdFile=$(mktemp)

for b in ${benchmarks[@]}
do
   for p in ${platforms[@]}
   do
      input=""
      if [[ $p == "hw" ]]
      then
         input="native"
      else
         input="small"
      fi
      echo "./run.sh $b $p $input" >> $cmdFile
   done
done

parallel -j6 < $cmdFile

rm $cmdFile
