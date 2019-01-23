#!/bin/bash
#Robert Ietswaart - MIT license 
#Note: if you are using a 6nt Barcode/UMI instead of 10nt: then delete _N10 in script name (line 58): molecularBarcodeExtraction.sh

# set path for folder with current script and complete fields in parameters file before running
cd /home/code
parameterFiles=NETseq_align_parameters.in

#load modules on SLURM (adjust for LSF or comment out when using locally installed programs)
module load gcc/6.2.0
module load bedops/2.4.30
module load python/2.7.12
module load htseq/0.9.1
module load bedtools/2.26.0
module load samtools/0.1.19

##########################################################################################
echo $parameterFiles 

baseDir=`grep "Base Directory"            $parameterFiles | perl -pe 's/^.*?(:)//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'`
samples=`grep "Sample Names"           $parameterFiles | perl -pe 's/^.*?(:)//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'`
indexDi=`grep "Index Directory"            $parameterFiles | perl -pe 's/^.*?(:)//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'`
initDir=`grep "Initial Files Directory"     $parameterFiles | perl -pe 's/^.*?(:)//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'`
notifEm=`grep "Notification Email"       $parameterFiles | perl -pe 's/^.*?(:)//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'`
scriptD=`grep "Scripts Directory"         $parameterFiles | perl -pe 's/^.*?(:)//' | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//'`

mkdir -p $baseDir

##########################################################################################
# split files

I_suffix_1='.fastq'         # input file suffix and extension
O_suffix_1='_split.fastq.'  # output file suffix and extension
nbLines=80000000            # maximum number of lines contained per split files: 80M

for f in `echo -e $samples`
do
    pushd $initDir
    echo "counting number of lines in " $f
    myVar=`wc -l ${f}${I_suffix_1} | cut -f 1 --delim=" "` ; echo $(($myVar / $((nbLines)) +1)) > ${f}_nbSplit.txt
    popd

done

# splittingFiles: split files into workable size
bash splittingFiles.sh $samples $initDir $I_suffix_1 $O_suffix_1 $nbLines 2>${baseDir}/splittingFiles.log

##########################################################################################
# extract molecular barcode from fastq

I_suffix_1='_split.fastq'                     # input file suffix and extension
I_suffix_2='_nbSplit.txt'                     # input file nb of Split suffix and extension
O_suffix_1='_split_noBarcode.fastq'           # output file 1 suffix and extension
O_suffix_2='_split_barcodeDistribution.txt'   # output file 2 suffix and extension
O_suffix_3='_split_ligationDistribution.txt'  # output file 3 suffix and extension

# molecularBarcodeExtraction: remove molecular barcodes from reads
bash molecularBarcodeExtraction_N10.sh $samples $scriptD $initDir $I_suffix_1 $I_suffix_2 $O_suffix_1 $O_suffix_2 $O_suffix_3 2>${baseDir}/MBextraction.log

##########################################################################################
# get quality information with fastQC

I_suffix_1='_split_noBarcode.fastq'           # input file suffix and extension
I_suffix_2='_nbSplit.txt'                     # input file nb of Split suffix and extension

#fastQC: check quality of reads
bash qualityCheck_O2.sh $samples $initDir $I_suffix_1 $I_suffix_2 2>${baseDir}/fastQC.log
