#!/usr/bin/env python

"""
RI20171009
adjusted to handle N10 instead of N6 barcode from script: extractMolecularBarcode.py by Julia di Iulio

script used to extract molecular barcodes from the reads (fastq format) but keeping them associated to the read.
Running the script will output :
        a new fastq file (with the molecular barcode removed from the read sequence, but the information is kept in the
        header of the read)
        a file containing the molecular barcode counts
        a file containing the ligation hexamer counts

The two files containing the counts can be further used to investigate the distribution of the molecular barcodes and/or
the ligation hexamers (script not provided).

use : python extractMolecularBarcode_N10.py inFastq outFastq outBarcodes outLigation

"""

import sys, itertools

iFastq=open(sys.argv[1], 'r')
oFastq=open(sys.argv[2], 'w')
oBarcode=open(sys.argv[3], 'w')
oLigation=open(sys.argv[4], 'w')

dicoBarcode={}  # creates a dictionnary that will contain Molecular Barcode counts (see below)
dicoLigation={} # creates a dictionnary that will contain ligation hexamer counts (see below): why do we do this? Just a QC
nct='ACTGN'     # nct stands for nucleotide

# fill two dictionaries with the keys being all possible molecular barcodes/ligation hexamers made with the letters 'A', 'C', 'G',
# 'T' and 'N', and the values being set to 0 for now; the values will be incremented every time a molecular barcode/ligation hexamers
# is identified in a read
for barcode in list(itertools.product(nct, repeat=10)):#RIedit1
    dicoBarcode["".join(barcode)] = 0
for barcode in list(itertools.product(nct, repeat=6)):#RIedit1a
    dicoLigation["".join(barcode)] = 0


header= iFastq.readline().rstrip() # reads the first line of the fastq file (which corresponds to the header of the first read)
while header != '':
    totseq   = iFastq.readline() # reads the sequence of the first read (the first 10 nucleotides being the molecular barcode (MBC))
    plus     = iFastq.readline() # reads the 3rd line of a read in a fastq format
    totqual  = iFastq.readline() # reads the quality of the read (also containing the PHRED quality score of the MBC)
    barcode  = totseq[0:10]    # assigns the 10 first nucleotide (nt) of the read sequence to the variable "barcode" RIedit2
    ligation = totseq[7:13]    # assigns the last 3 nts of the MBC and the first 3 nts of the RNA fragment to the variable "ligation" RIedit3
    seq  = totseq[10:]         # assigns the RNA fragment sequence to the variable "seq" RIedit4
    qual = totqual[10:]        # assigns the RNA fragment PHRED quality score to the variable "qual" RIedit5
    oFastq.write(header.split(" ")[0]+'_MolecularBarcode:'+barcode+' '+header.split(" ")[1]+'\n')
    # writes the header of the reads (containing the MBC info) to the output fastq file
    oFastq.write(seq)  # writes the RNA fragment sequence to the output fastq file
    oFastq.write(plus) # writes the 3rd line of a read in a fastq format to the output fastq file
    oFastq.write(qual) # writes the RNA fragment PHRED quality score to the output fastq file
    header= iFastq.readline().rstrip() # read the header of the following read
    dicoBarcode[barcode] += 1 # adds 1 count in the MBC dictionary to the specific MBC found in the read
    dicoLigation[ligation] += 1 # adds 1 count in the ligation dictionary to the specific ligation found in the read

for barcode, times in dicoBarcode.items():              # outputs a file containing each possible MBC (column 1) and the respective
    oBarcode.write("%s\t%s\n" % (barcode, str(times)))  # number of times (column 2) it was found in a read.

for ligation, times in dicoLigation.items():            # outputs a file containing each possible ligation hexamer (column 1) and
    oLigation.write("%s\t%s\n" % (ligation, str(times)))# the respective number of times (column 2) it was found in a read

# close files
iFastq.close()
oFastq.close()
oBarcode.close()
oLigation.close()

