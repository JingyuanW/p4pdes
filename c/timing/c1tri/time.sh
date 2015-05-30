#!/bin/bash

set +x

function run() {
  rm -f tmp
  set -x
  /usr/bin/time -f "%e" mpiexec -n $1 ../../c1tri -tri_m 10000000 -ksp_type $2 -pc_type $3 $4 &> tmp
  set +x
  NAME=$2.$3.$1
  rm -f $NAME
  cat tmp |tail -n 1 &> $NAME
  rm tmp
  cat $NAME
}

for PC in lu cholesky; do
    run 1 preonly $PC ""
done
for KSP in gmres cg; do
    for N in 1 4; do
        for PC in none jacobi; do
            run $N $KSP $PC ""
        done
    done
done
run 1 gmres ilu ""
run 4 gmres bjacobi "-sub_pc_type ilu"
run 1 cg icc ""
run 4 cg bjacobi "-sub_pc_type icc"

