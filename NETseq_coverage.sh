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
#calculate coverage from aligned reads

Isuf1='_Aligned.sortedByCoord.out'                 # suffix of raw alignment file no barcode (noBC)
Isuf2='_noRTbias'                     # input file nb of Split suffix and extension
Isuf3='_noRTbias_uniq'                 # suffix of alignment file output 
Isuf4='_noRTbias_noPCRdup_uniq'                 # suffix of alignment file output 
Isuf5='_noRTbias_noPCRdup_noSI_uniq'                 # suffix of alignment file output 
Osuf1='_noBC'                       # output suffix of raw alignment file no barcode (noBC)
Osuf2='_noRTbias'                       # output suffix for the coverage files
Osuf3='_noRTbias_uniq'                       # output suffix for the coverage files
Osuf4='_noRTbias_noPCRdup_uniq'                       # output suffix for the coverage files
Osuf5='_noRTbias_noPCRdup_noSI_uniq'                       # output suffix for the coverage files

FILES=`echo -e ${samples}`
inDir=$initDir
sttDir=$baseDir
Chr='' 

echo "generating Coverage and PolII position ... "

program=samtools
script=${scriptD}/customCoverage.py

#loopStart,f
for f in $FILES
do
    echo "Doing file "$f
    cd ${inDir}
    outDir=${sttDir}/CoverageSTAR/${f}
    mkdir -p ${outDir}/LogErr
    cd ${sttDir}/STAR/${f}/

    #O2 / SLURM
    Bam=${f}${Chr}${Isuf1}.bam
    sbatch -p medium --mem-per-cpu=40G -t 0-48:00:00 --job-name=${f}${Chr}${Osuf1}_calculateCoverage \
	-o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf1}.log -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf1}.err \
	--mail-user=${notifEm} --mail-type=END \
	--wrap="$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf1%_}"
    Bam=${f}${Chr}${Isuf2}.bam
    sbatch -p medium --mem-per-cpu=40G -t 0-48:00:00 --job-name=${f}${Chr}${Osuf2}_calculateCoverage \
	-o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf2}.log -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf2}.err \
	--mail-user=${notifEm} --mail-type=END \
	--wrap="$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf2%_}"
    Bam=${f}${Chr}${Isuf3}.bam
    sbatch -p short --mem-per-cpu=4G -t 0-11:59:00 --job-name=${f}${Chr}${Osuf3}_calculateCoverage \
	-o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf3}.log -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf3}.err \
	--mail-user=${notifEm} --mail-type=END \
	--wrap="$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf3%_}"
    Bam=${f}${Chr}${Isuf4}.bam
    sbatch -p short --mem-per-cpu=4G -t 0-11:59:00 --job-name=${f}${Chr}${Osuf4}_calculateCoverage \
	-o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf4}.log -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf4}.err \
	--mail-user=${notifEm} --mail-type=END \
	--wrap="$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf4%_}"
    Bam=${f}${Chr}${Isuf5}.bam
    sbatch -p short --mem-per-cpu=4G -t 0-11:59:00 --job-name=${f}${Chr}${Osuf5}_calculateCoverage \
	-o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf5}.log -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf5}.err \
	--mail-user=${notifEm} --mail-type=END \
	--wrap="$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf5%_}"

    #Orchestra /LSF
    # Bam=${f}${Chr}${Isuf1}.bam
    # bsub -q medium -W 48:00 -R "rusage[mem=40000]" -J ${f}${Chr}_calculateCoverage -o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf1}.log \
    #    -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf1}.err -u ${notifEm} -N \
    #    "$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf1%_}"
    # Bam=${f}${Chr}${Isuf2}.bam
    # bsub -q medium -W 48:00 -R "rusage[mem=40000]" -J ${f}${Chr}_calculateCoverage -o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf2}.log \
    #     -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf2}.err -u ${notifEm} -N \
    #     "$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf2%_}"
    # Bam=${f}${Chr}${Isuf3}.bam
    # bsub -q short -W 11:59 -J ${f}${Chr}_calculateCoverage -o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf3}.log \
    #     -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf3}.err -u ${notifEm} -N \
    #     "$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf3%_}"
    # Bam=${f}${Chr}${Isuf4}.bam
    # bsub -q short -W 11:59 -J ${f}${Chr}_calculateCoverage -o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf4}.log \
    #     -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf4}.err -u ${notifEm} -N \
    #     "$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf4%_}"
    # Bam=${f}${Chr}${Isuf5}.bam
    # bsub -q short -W 11:59 -J ${f}${Chr}_calculateCoverage -o ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf5}.log \
    #     -e ${outDir}/LogErr/${f}${Chr}_calculateCoverage${Osuf5}.err -u ${notifEm} -N \
    #     "$program view ${Bam} | sed 's/\tjM.*$//' | python $script ${outDir}/${f}${Chr}${Osuf5%_}"

done
