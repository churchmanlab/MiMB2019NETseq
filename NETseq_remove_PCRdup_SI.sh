#!/bin/bash
#Robert Ietswaart - MIT license 


# set path for folder with current script and parameters file before running
cd /home/code
parameterFiles=NETseq_align_parameters.in
SIfile=/home/genomes/hg38/hg38_GENCODE_V24_ex_in_3end_siteCoordinates_1based.txt #annotation file containing 3' ends of exons and introns: provided in github repo

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
# remove PCR duplicates and splicing intermediates

Isuf1='_noRTbias_uniq'                 # suffix of alignment file output after RT bias removal and merging
Osuf1='_noRTbias_noPCRdup_'              # output alignment/bg file suffix after PCR dup removal

FILES=`echo -e $samples`
sttDir=$baseDir

echo "removing PCR duplicates and Splicing intermediates from bam files ... "

program=python
script=${scriptD}/removeSIandPCRdups.py 

for f in $FILES
do
    echo "Doing file "$f
    inBamDir=${sttDir}/STAR/${f}/
    iBamUniq=${inBamDir}/${f}${Isuf1}.bam
    oBamUniq=${inBamDir}/${f}${Osuf1}uniq.bam
    oBamUniqnoSI=${inBamDir}/${f}${Osuf1}noSI_uniq.bam

    # removePCRdupUniq
    #O2 / SLURM
    sbatch -p short --mem-per-cpu=4G -t 0-11:59:00 --job-name=${f}_removePCRdup \
	-o ${inBamDir}/LogErr/${f}_removePCRdups.log -e ${inBamDir}/LogErr/${f}_removePCRdups.err \
	--mail-user=${notifEm} --mail-type=END \
	--wrap="$program $script $iBamUniq $SIfile $oBamUniq $oBamUniqnoSI"

    # #Orchestra / LSF
    # bsub -q short -W 11:59 -J ${f}_removePCRdups -o ${inBamDir}/LogErr/${f}_removePCRdups.log \
    #     -e ${inBamDir}/LogErr/${f}_removePCRdups.err -u ${notifEm} -N \
    #     "python $script $iBamUniq $SIfile $oBamUniq $oBamUniqnoSI"

done
