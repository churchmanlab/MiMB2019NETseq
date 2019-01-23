#!/bin/bash
#Robert Ietswaart - MIT license 


# set path for folder with current script and complete fields in parameters file before running
cd /home/code
parameterFiles=NETseq_align_parameters.in
program=/home/STAR/STAR-2.5.1a/bin/Linux_x86_64/STAR

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
# align reads with barcode 
# STARwithBC: aligns reads still containing molecular barcode on provided genome

Isuf1='_split.fastq'                     # input file suffix and extension
Isuf2='_nbSplit.txt'                     # input file nb of Split suffix and extension
Osuf1='_withBC_'                         # output file suffix (after sample name) in STAR output

FILES=`echo -e $samples`
inDir=$initDir
sttDir=$baseDir
idxDir=$indexDi

echo "Aligning reads containing Molecular Barcode ... "

pFile=${scriptD}/Parameters_STAR.in

#loopStart,f
for f in $FILES
do
    echo "Doing file "$f
    cd ${inDir}
    nbSplit=`less ${f}${Isuf2}`
    read1=${f}${Isuf1}
    mkdir -p ${sttDir}/STAR/${f}${Osuf1%_}/LogErr
    outDir=${sttDir}/STAR/${f}${Osuf1%_}
    cd ${sttDir}/STAR/${f}${Osuf1%_}/

    for nb in `seq $nbSplit`
    do
        # STAR: performs alignment with specified reads 
	#O2 / SLURM
	sbatch -n 4 --mem-per-cpu=15G -t 0-11:47:00 --job-name=STAR_wBC_${f}_${nb} \
	    -o ${outDir}/LogErr/STAR_wBC_${f}_${nb}.log -e ${outDir}/LogErr/STAR_wBC_${f}_${nb}.err \
	    -p short --mail-user=${notifEm} --mail-type=END \
	    --wrap="$program --genomeDir ${idxDir} --readFilesIn ${inDir}/${read1}.${nb} \
            --runThreadN 4 --parametersFiles ${pFile} --outFileNamePrefix ${f}.${nb}${Osuf1}"

	#Orchestra / LSF
        # bsub -n 4 -R "rusage[mem=15000] span[ptile=4]" -W 11:47 -J STAR_wBC_${f}_${nb} \
        #     -o ${outDir}/LogErr/STAR_wBC_${f}_${nb}.log -e ${outDir}/LogErr/STAR_wBC_${f}_${nb}.err \
        #     -q mcore -u ${notifEm} -N \
        #     "$program --genomeDir ${idxDir} --readFilesIn ${inDir}/${read1}.${nb} \
        #     --runThreadN 4 --parametersFiles ${pFile} --outFileNamePrefix ${f}.${nb}${Osuf1}"
                  
    done
done

##########################################################################################
# align reads without barcode 

Isuf1='_split_noBarcode.fastq'           # input file suffix and extension
Isuf2='_nbSplit.txt'                     # input file nb of Split suffix and extension
Osuf1='_'                                # output file suffix (after sample name) in STAR output

FILES=`echo -e $samples`
inDir=$initDir
sttDir=$baseDir
idxDir=$indexDi

echo "Aligning reads NOT containing Molecular Barcode ... "

pFile=${scriptD}/Parameters_STAR.in

for f in $FILES
do
    echo "Doing file "$f
    cd ${inDir}
    nbSplit=`less ${f}${Isuf2}`
    read1=${f}${Isuf1}
    mkdir -p ${sttDir}/STAR/${f}${Osuf1%_}/LogErr
    outDir=${sttDir}/STAR/${f}${Osuf1%_}
    cd ${sttDir}/STAR/${f}${Osuf1%_}/

    for nb in `seq $nbSplit`
    do
        # STAR: performs alignment with specified reads
	#O2 / SLURM
	sbatch -n 4 --mem-per-cpu=15G -t 0-11:47:00 --job-name=STAR_${f}_${nb} \
	    -o ${outDir}/LogErr/STAR_${f}_${nb}.log -e ${outDir}/LogErr/STAR_${f}_${nb}.err \
	    -p short --mail-user=${notifEm} --mail-type=END \
	    --wrap="$program --genomeDir ${idxDir} --readFilesIn ${inDir}/${read1}.${nb} \
            --runThreadN 4 --parametersFiles ${pFile} --outFileNamePrefix ${f}.${nb}${Osuf1}"

	# #Orchestra / LSF
        # bsub -n 4 -R "rusage[mem=15000] span[ptile=4]" -W 11:47 -J STAR_${f}_${nb} \
        #     -o ${outDir}/LogErr/STAR_${f}_${nb}.log -e ${outDir}/LogErr/STAR_${f}_${nb}.err \
        #     -q mcore -u ${notifEm} -N \
        #     "$program --genomeDir ${idxDir} --readFilesIn ${inDir}/${read1}.${nb} \
        #     --runThreadN 4 --parametersFiles ${pFile} --outFileNamePrefix ${f}.${nb}${Osuf1}"
                  
    done
done
