#!/usr/bin/env bash


tar -cvf archive.tar *

MDSUM=`md5 -q archive.tar`

echo $MDSUM

mv archive.tar archive_$MDSUM.tar

echo sleeping for $1 seconds

sleep $1

