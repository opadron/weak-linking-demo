#! /usr/bin/env bash

for L in s d ; do
    for M in 0 1 ; do
        for E in 0 1 ; do
            echo "$L$M$E"
        done
    done
done | ./enumerateBuild.bash

