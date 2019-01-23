#!/usr/bin/env bash

# Description:
#                       splitting files into smaller ones (containing maximum <lines> number of lines)
#
# Input Name(s) :
#                       <Sample Name><I_suffix_1>       # ex: I_suffix_1='.fastq'
#
# Output Name(s) :
#                       <Sample Name><O_suffix_1>[a-z]  # ex: O_suffix_1='_split.fastq.'
#
# Program/commands:
#                       split

FILES=`echo -e $1`
inDir=$2
Isuf1=$3
Osuf1=$4
lines=$5



echo "Splitting... "

#loopStart,f
for f in $FILES
do
    echo "Doing file "$f
    cd ${inDir}
    input1=${f}${Isuf1}
    output1=${f}${Osuf1}

    #@101,0,split: split files into workable size
    split --lines=${lines} -a 2 ${input1} ${output1}

    splitFiles=`ls ${output1}*`
    i=1
    for fs in $splitFiles
    do
        echo "renaming split " ${fs}
        mv $fs ${output1}${i}
        let i++
    done

#loopEnd
done

