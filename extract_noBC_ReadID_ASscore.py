#!/usr/bin/env python

"""
RI20171015
adjusted from extractReadsWithMismatchesIn6FirstNct.py
this one is bug free
"""

import sys, pysam, re

iBAM = pysam.Samfile("-", 'r') # reads from the standard input

for line in iBAM:
    for tag in line.tags:
        if tag[0]=='AS':
            AS=str(tag[1]) 
    print ('\t'.join([line.query_name , AS]))
 
# close file
iBAM.close()


