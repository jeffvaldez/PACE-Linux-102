#!/usr/bin/bash

for DATATYPE in {numerical,binary,lorem,random}
do 
    ls -l content/$DATATYPE* | awk -v DT=$DATATYPE '{print "****** "DT".txt - "$5" bytes *********"}'
    for COMPRESSOR in {gzip,bzip2,xz}
    do 
	COMPTIME=$((time tar -I$COMPRESSOR -cf $DATATYPE.tar.$COMPRESSOR content/$DATATYPE.txt) 2>&1 | awk '/real/ {print $2}')
	COMPSIZE=$(ls -l *.$COMPRESSOR | awk '{print $5}')
	DECOTIME=$((time tar -I$COMPRESSOR -xf $DATATYPE.tar.$COMPRESSOR) 2>&1 | awk '/real/ {print $2}')
	printf '%-10s %-10s %-10s %-10s\n' $COMPRESSOR $COMPTIME $DECOTIME $COMPSIZE
    done
    rm *.tar.*
done
