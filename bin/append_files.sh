#!/usr/bin/env bash

# appends phrase to the end of file. adds app extention 

PHRASE=' Is it Friday yet?'

for f in * 
do
 cat $f > $f.tmp
 echo $PHRASE >> $f.tmp
 mv $f.tmp $f.app
 echo Appended $PHRASE to file: $f.app 
done

echo sleeping for $1 seconds

sleep $1

