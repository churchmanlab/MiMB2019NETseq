#!/bin/bash
#Robert Ietswaart - MIT license 
#Note: if you are using a 6nt Barcode/UMI: then replace 10 with 6 in sbatch awk command (line 74):


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

# ##########################################################################################
# remove reads resulting from RT mispriming

Isuf1='_'                                # suffix of alignment file output from alignReads.sh
Isuf2='_withBC_'                         # suffix of alignment file output from alignReads2.sh
Isuf3='_nbSplit.txt'                     # input file nb of Split suffix and extension
Osuf1='_noRTbias'         # output alignment file suffix after RT bias removal

FILES=`echo -e $samples`
inDir=$initDir
sttDir=$baseDir

echo "removing reads with RT bias (with AS score method) ... "

program=samtools
script1=${scriptD}/extract_noBC_ReadID_ASscore.py 
script2=${scriptD}/extract_withBC_ReadID_ASscore.py 

#loopStart,f
for f in $FILES
do
    echo "Doing file "$f
    cd ${inDir}
    nbSplit=`less ${f}${Isuf3}`
    comDir=${sttDir}/STAR/
    cd $comDir

    #loopStart,nb
    for nb in `seq $nbSplit`
    do
	Bam1=${f}${Isuf1%_}/${f}.${nb}${Isuf1}Aligned.sortedByCoord.out.bam
	Bam2=${f}${Isuf2%_}/${f}.${nb}${Isuf2}Aligned.sortedByCoord.out.bam
	folder=${f}${Isuf1%_}
    
        # removeRTbias: removes reads that arise from RT biases
	#SLURM command
	sbatch -p short --mem-per-cpu=16G -t 0-11:59:00 --job-name=${f}_${nb}_noRTbias \
	    -o ${comDir}/${f}${Isuf1%_}/LogErr/${f}_${nb}_noRTbias.log -e ${comDir}/${f}${Isuf1%_}/LogErr/${f}_${nb}_noRTbias.err \
	    --mail-user=${notifEm} --mail-type=END \
	    --wrap="$program view -H ${Bam1} > ${folder}/headers.${nb}.sam; \ 
$program view ${Bam1} | sed 's/_MolecularBarcode/\t_MB/' | sort -k1,1 > ${folder}/temp.sam.${nb}; \ 
$program view -h ${Bam1} | python ${script1} | sort -k1,1 | uniq | sed 's/_MolecularBarcode:[NATCG]*//' > ${folder}/rtBiasnames_noBC.txt.${nb}; \
$program view -h ${Bam2} | python ${script2} | sort -k1,1 | uniq > ${folder}/rtBiasnames_withBC.txt.${nb}; \
sort -k1,1 ${folder}/rtBiasnames_noBC.txt.${nb} | join -t $'\t' - ${folder}/rtBiasnames_withBC.txt.${nb} > ${folder}/rtBiasnames.txt.${nb}.temp; \        
awk -F '\t' '{if(NF==3 && \$3 >= (\$2 + 10)){print \$1} }' ${folder}/rtBiasnames.txt.${nb}.temp | sort -k1,1 > ${folder}/rtBiasnames.txt.${nb}; \ 
join -v 1 ${folder}/temp.sam.${nb} ${folder}/rtBiasnames.txt.${nb} | sed -e 's/ _MB/_MolecularBarcode/' -e 's/ /\t/g'| \
cat ${folder}/headers.${nb}.sam - | $program view -Sb -o ${folder}/temp_noRTbias.bam.${nb} - ; \
$program sort ${folder}/temp_noRTbias.bam.${nb} ${folder}/${f}${Osuf1}.${nb}; \
rm ${folder}/temp.sam.${nb}; rm ${folder}/temp_noRTbias.bam.${nb}; rm ${folder}/headers.${nb}.sam; rm ${folder}/rtBiasnames.txt.${nb}; \
rm ${folder}/rtBiasnames_noBC.txt.${nb}; rm ${folder}/rtBiasnames_withBC.txt.${nb}; rm ${folder}/rtBiasnames.txt.${nb}.temp; "

       # 	#LSF command 
       # 	bsub -q short -W 11:59 -J ${f}_STAR_noBias -o ${comDir}/${f}${Isuf1%_}/LogErr/${f}_${nb}_STAR_noBias.log \
       #      -e ${comDir}/${f}${Isuf1%_}/LogErr/${f}_${nb}_STAR_noBias.err -u ${notifEm} -N \
       # 	    "$program view -H ${Bam1} > ${folder}/headers.${nb}.sam ; \ 
       # $program view ${Bam1} | sed 's/_MolecularBarcode/\t_MB/' | sort -k1,1 > ${folder}/temp.sam.${nb} ; \ 
       # $program view -h ${Bam1} | python ${script1} | sort -k1,1 | uniq | sed 's/_MolecularBarcode:[NATCG]*//'  > ${folder}/rtBiasnames_noBC.txt.${nb} ; \
       # $program view -h ${Bam2} | python ${script2}  | sort -k1,1 | uniq > ${folder}/rtBiasnames_withBC.txt.${nb} ; \
       # sort -k1,1 ${folder}/rtBiasnames_noBC.txt.${nb} | join -t $'\t' - ${folder}/rtBiasnames_withBC.txt.${nb} > ${folder}/rtBiasnames.txt.${nb}.temp ; \        
       # awk -F '\t' '{if(NF==3 && \$3 >= (\$2 + 10)){print \$1} }' ${folder}/rtBiasnames.txt.${nb}.temp  | sort -k1,1 > ${folder}/rtBiasnames.txt.${nb} ; \ 
       # join -v 1 ${folder}/temp.sam.${nb} ${folder}/rtBiasnames.txt.${nb} | sed -e 's/ _MB/_MolecularBarcode/' -e 's/ /\t/g'| \
       # cat ${folder}/headers.${nb}.sam - | $program view -Sb -o ${folder}/temp_noRTbias.bam.${nb} - ; \
       # $program sort ${folder}/temp_noRTbias.bam.${nb} ${folder}/${f}${Osuf1}.${nb} ; \
       # $program index ${folder}/${f}${Osuf1}.${nb} ; \
       # rm ${folder}/temp.sam.${nb} ; rm ${folder}/temp_noRTbias.bam.${nb}; \
       # rm ${folder}/rtBiasnames_noBC.txt.${nb} ; rm ${folder}/rtBiasnames_withBC.txt.${nb} ; rm ${folder}/rtBiasnames.txt.${nb}.temp; "

    done
done
