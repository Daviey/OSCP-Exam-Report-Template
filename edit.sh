#!/bin/sh

for i in $(grep -l TODO Lab/Exercises/*.md | sort -V | uniq); do
  vim $i
done
