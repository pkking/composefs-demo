#!/bin/bash

set -e 
set -x 

imagetag="openeuler/openeuler:24.03-lts openeuler/openeuler:24.03-lts-sp1"

for img in $imagetag;do
    docker export --output output.tar $(docker create $img)
    mkdir -p $(basename $img)
    tar xf output.tar -C $(basename $img)
done

rm output.tar