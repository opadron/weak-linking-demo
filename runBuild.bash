#! /usr/bin/env bash

if [ '!' -d "_build/$1" ] ; then
    ./enumerateBuild.bash "$1"
fi

cd _build/$1
./main
exit $?

