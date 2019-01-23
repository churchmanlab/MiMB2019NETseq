#!/bin/bash
#Robert Ietswaart - MIT license 


# set path for folder with current script and parameters file before running
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
# merge bam files for noBC after splitting.

Isuf1='_Aligned.sortedByCoord.out'       # input suffix for the bam files that you want to merge together

FILES=`echo -e $samples`
inDir=$initDir
sttDir=$baseDir

echo "concatenate noBC bam files ... "

program=samtools

for f in $FILES
do
    echo "Doing file "$f
    cd ${inDir}
    outDir=${sttDir}/STAR/${f}
    mkdir -p ${outDir}/LogErr
    cd $outDir
  
    #O2 / SLURM
    #in case of multiple bam files
    sbatch -p short --mem-per-cpu=2G -t 0-11:59:00 --job-name=${f}_mergeBAM_raw \
	-o ${outDir}/LogErr/${f}_mergeBAM_raw.log -e ${outDir}/LogErr/${f}_mergeBAM_raw.err \
	--mail-user=${notifEm} --mail-type=END \
	--wrap="$program merge -f -r ${f}${Isuf1}.bam ${f}.*${Isuf1}.bam; \
        $program index ${f}${Isuf1}.bam ; "

    # # in case you only have 1 bam file
    # sbatch -p short --mem-per-cpu=2G -t 0-11:59:00 --job-name=${f}_mergeBAM_raw \
    # 	-o ${outDir}/LogErr/${f}_mergeBAM_raw.log -e ${outDir}/LogErr/${f}_mergeBAM_raw.err \
    # 	--mail-user=${notifEm} --mail-type=END \
    # 	--wrap="mv ${f}.1${Isuf1}.bam ${f}${Isuf1}.bam; \
    #     $program index ${f}${Isuf1}.bam ; "

    # #Orchestra / LSF
    # #in case of multiple bam files
    # bsub -q short -W 11:59 -J ${f}_mergeBAM_raw -o ${outDir}/LogErr/${f}_mergeBAM_raw.log \
    #     -e ${outDir}/LogErr/${f}_mergeBAM_raw.err -u ${notifEm} -N \
    #     "$program merge -f -r ${f}${Isuf1}.bam ${f}.*${Isuf1}.bam; \
    #     $program index ${f}${Isuf1}.bam ; "
    # # in case you only have 1 bam file
    # bsub -q short -W 11:59 -J ${f}_mergeBAM_raw -o ${outDir}/LogErr/${f}_mergeBAM_raw.log \
    #     -e ${outDir}/LogErr/${f}_mergeBAM_raw.err -u ${notifEm} -N \
    #     "mv ${f}.1${Isuf1}.bam ${f}${Isuf1}.bam; \
    #     $program index ${f}${Isuf1}.bam ; "

done

##########################################################################################
# merge RTbias  bam files after splitting and also output unique alignments bam

# if you have only 1 file per sample, skip this step and just rename the file
Isuf1='_noRTbias'            # input suffix for the bam files that you want to merge together
Isuf2='_nbSplit.txt'                     # input file nb of Split suffix and extension

FILES=`echo -e $samples`
inDir=$initDir
sttDir=$baseDir

echo "concatenate no RTbias bam (with AS method) files ... "

program=samtools

for f in $FILES
do
    echo "Doing file "$f
    cd ${inDir}
    nbSplit=`less ${f}${Isuf2}`
    outDir=${sttDir}/STAR/${f}
    mkdir -p ${outDir}/LogErr
    cd $outDir

    #O2 / SLURM
    #in case of multiple bam files
    sbatch -p short --mem-per-cpu=2G -t 0-11:59:00 --job-name=${f}_mergeBAM_noRT \
	-o ${outDir}/LogErr/${f}_mergeBAM_noRT.log -e ${outDir}/LogErr/${f}_mergeBAM_noRT.err \
	--mail-user=${notifEm} --mail-type=END \
	--wrap="$program merge -f -r ${f}${Isuf1}.bam ${f}${Isuf1}.*.bam; \
        $program index ${f}${Isuf1}.bam ; \
        $program view -h -q 50 ${f}${Isuf1}.bam | $program view -Sb -o ${f}${Isuf1}_uniq.bam - ; \
        $program index ${f}${Isuf1}_uniq.bam"

    # # in case of one bam file: no merge, just mv
    # sbatch -p short --mem-per-cpu=2G -t 0-11:59:00 --job-name=${f}_mergeBAM_noRT \
    # 	-o ${outDir}/LogErr/${f}_mergeBAM_noRT.log -e ${outDir}/LogErr/${f}_mergeBAM_noRT.err \
    # 	--mail-user=${notifEm} --mail-type=END \
    # 	--wrap="mv ${f}${Isuf1}.1.bam ${f}${Isuf1}.bam; \
    #     $program index ${f}${Isuf1}.bam ; \
    #     $program view -h -q 50 ${f}${Isuf1}.bam | $program view -Sb -o ${f}${Isuf1}_uniq.bam - ; \
    #     $program index ${f}${Isuf1}_uniq.bam"

    # #Orchestra / LSF
    # #in case of multiple bam files: 
    # # mergeBamAll: merging bam file with uniquely/or all aligned reads (noRTbias)
    # bsub -q short -W 11:59 -J ${f}_mergeBAM_neg -o ${outDir}/LogErr/${f}_mergeBAM_neg.log \
    #     -e ${outDir}/LogErr/${f}_mergeBAM_neg.err -u ${notifEm} -N \
    #     "$program merge -f -r ${f}${Isuf1}.bam ${f}${Isuf1}.*.bam; \
    #     $program index ${f}${Isuf1}.bam ; \
    #     $program view -h -q 50 ${f}${Isuf1}.bam | $program view -Sb -o ${f}${Isuf1}_uniq.bam - ; \
    #     $program index ${f}${Isuf1}_uniq.bam"
    # # in case of one bam file: no merge, just mv
    # # mergeBamAll: merging bam file with uniquely/or all aligned reads (noRTbias.sorted)
    # bsub -q short -W 11:59 -J ${f}_mergeBAM_neg -o ${outDir}/LogErr/${f}_mergeBAM_neg.log \
    #     -e ${outDir}/LogErr/${f}_mergeBAM_neg.err -u ${notifEm} -N \
    #     "mv ${f}${Isuf1}.1.bam ${f}${Isuf1}.bam; \
    #     $program index ${f}${Isuf1}.bam ; \
    #     $program view -h -q 50 ${f}${Isuf1}.bam | $program view -Sb -o ${f}${Isuf1}_uniq.bam - ; \
    #     $program index ${f}${Isuf1}_uniq.bam"

done
