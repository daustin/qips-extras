#!/usr/bin/env bash

# reverses contents of file and appends rev extention

for f in * 
do
 rev $f > $f.tmp
 mv $f.tmp $f.rev
 echo reversed file: $f.rev 
done

echo sleeping for $1 seconds

sleep $1

