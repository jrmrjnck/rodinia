#!/bin/bash

benchmarks=(backprop bfs b+tree cfd gaussian heartwall hotspot kmeans lavaMD lud mummergpu myocyte nn nw particlefilter pathfinder srad streamcluster)
platforms=(hw)

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
         input="medium"
      fi
      echo "./run.sh $b $p $input" >> $cmdFile
   done
done

# Let simulations run for 5 hours
parallel -j1 --timeout $(calc 5*60*60) < $cmdFile

rm $cmdFile
