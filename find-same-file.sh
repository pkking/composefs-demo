#!/bin/bash

# given two dir, find all same file in these dirs
DIR1=$1
DIR2=$2

diff -srq $DIR1 $DIR2 | grep identical