#!/usr/bin/env bash
# Description:
#                       Fastq Quality Check ...
#
# Inputs:
#                       <Sample Name><I_suffix_1>   # ex: I_suffix_1='_split_noBarcode.fastq'
#                       <Sample Name><I_suffix_2>   # ex: I_suffix_2='_nbSplit.txt'
#
# Outputs:
#                       <SampleName><I_suffix_1%.fastq>_[1-9]*_fastqc.zip    # ex: O_suffix_1='_split_noBarcode_fastqc.zip'
#
# Programs:
#                        fastqc
#

module load fastqc/0.11.5
module load java/jdk-1.8u112

FILES=`echo -e $1`
inDir=$2
Isuf1=$3
Isuf2=$4

echo "Fastq Quality Check ... "

#loopStart,f
for f in $FILES
do
    echo "Doing file "$f
    cd ${inDir}
    nbSplit=`less ${f}${Isuf2}`

    #loopStart,nb
    for nb in `seq $nbSplit`
    do
        #@301,200,fastqc: perform usual quality checks on fastq files
        fastqc ${f}${Isuf1}.${nb} --noextract -outdir $inDir --java java
        #@302,301,rename: rename zip files
        mv ${f}${Isuf1}.${nb}_fastqc.zip ${f}${Isuf1%.fastq}_${nb}_fastqc.zip
    #loopEnd
    done

#loopEnd
done
