#!/usr/bin/env python

"""
RI20171015
adjusted from extractReadsWithMismatchesIn6FirstNct.py
this one is bug free
"""

import sys, pysam, re

iBAM = pysam.Samfile("-", 'r') # reads from the standard input

for line in iBAM:
    md=re.findall(r'\d+', [tag[1] for tag in line.tags if tag[0]=='MD'][0])
    for tag in line.tags:
        if tag[0]=='AS':
            AS=str(tag[1]) 

    if len(md) == 1 :       # if there are no mismatches
        print ('\t'.join([line.query_name , AS]))
    else:
        if (not line.is_reverse) and (int(md[0]) >= 10): # if the first mismatch occurs after the 10th nt (from the 5' end) RIedit1
            print ('\t'.join([line.query_name , AS])) #write ID and alignment score to stdout
        elif (line.is_reverse) and (int(md[-1]) >= 10):  # same as above but for reads that align to the reverse strand RIedit2
            print ('\t'.join([line.query_name , AS]))

# close file
iBAM.close()


