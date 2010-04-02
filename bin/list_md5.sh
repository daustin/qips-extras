##################################################################
#
#   simple script that lists m5 for each file in the directory
#   no output files, just lists information
#
#

echo Listing MD5 sums for each file in directory...

for f in * 
do
 md5 $f 
done