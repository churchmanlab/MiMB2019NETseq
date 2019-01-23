#!/usr/bin/env bash

# Description:
#                       removal of 6 first nucleotide (molecular barcode) from FastQ files
#                       creates 2 additional files containing the molecular barcode/ligation hexamer counts
#
# Input Name(s) (provided in humanNETseq_pipeline.sh):
#                       <Sample Name><I_suffix_1>   # ex: I_suffix_1='_split.fastq'
#                       <Sample Name><I_suffix_2>   # ex: I_suffix_2='_nbSplit.txt'
#
# Output Name(s) (provided in humanNETseq_pipeline.sh):
#                       <Sample Name><O_suffix_1>   # ex: O_suffix_1='_split_noBarcode.fastq'
#                       <Sample Name><O_suffix_2>   # ex: O_suffix_2='_split_barcodeDistribution.txt'
#                       <Sample Name><O_suffix_3>   # ex: O_suffix_3='_split_ligationDistribution.txt'
#
# Program/commands:
#                       extractMolecularBarcode.py

FILES=`echo -e $1`
scriptDir=$2
inDir=$3
Isuf1=$4
Isuf2=$5
Osuf1=$6
Osuf2=$7
Osuf3=$8

echo "Extracting Molecular Barcode... "


#loopStart,f
for f in $FILES
do
    echo "Doing file "$f
    cd ${inDir}
    nbSplit=`less ${f}${Isuf2}`

    #loopStart,nb
    for nb in `seq $nbSplit`
    do
        #@201,101,extractMB: extract MB and output table distribution
        python ${scriptDir}/extractMolecularBarcode.py ${f}${Isuf1}.${nb} ${f}${Osuf1}.${nb} ${f}${Osuf2}.${nb} ${f}${Osuf3}.${nb}
    #loopEnd
    done

#loopEnd
done
