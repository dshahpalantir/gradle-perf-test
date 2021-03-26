#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

if [ $# -ne 2 ]; then
   echo "Usage: ./measure_gradle_performance.sh <number_of_projects> <number_of_iterations>" 
   exit 1
fi

git clean -dfx -e out
mkdir -p out

NUM_PROJECTS=$1
ITERATIONS=$2

out_file="out/projects_${NUM_PROJECTS}_iterations_${ITERATIONS}.txt"
for ((i = 1 ; i <= NUM_PROJECTS ; i++)); do
   mkdir project"$i"
   cp -r sample-project/* project"$i"
   echo "include('project$i')" >> settings.gradle
done

total_time=0
for ((i = 1 ; i <= ITERATIONS ; i++)); do
   rm -rf .gradle
   start_time=$(gdate +%s%N)
   ./gradlew -q --no-build-cache --no-configuration-cache --rerun-tasks :project1:build > /dev/null 2>&1
   end_time=$(gdate +%s%N)
   elapsed_time_in_milli=$(((end_time - start_time) / 1000))
   echo "iteration ${i} time in ms : " ${elapsed_time_in_milli} >> "${out_file}"
   total_time=$((total_time+elapsed_time_in_milli))
done

echo "average time for ${NUM_PROJECTS} projects over ${ITERATIONS} iterations in ms " $(((total_time / ITERATIONS))) >> "${out_file}"
git checkout settings.gradle
