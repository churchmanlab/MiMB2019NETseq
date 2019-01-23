#!/bin/bash
#Robert Ietswaart - MIT license

# Tasks: 
#	1. Create STAR index for human genome only
#                              or
#	2. In case a Drosophila spike in was used: Create STAR index for concatenated human/drosophila genome
#
##########################################################################################


#	1. Create human genome STAR index
module load dev/gcc-5.2.0
mkdir -p ~/genomes/hg38/STARindex/LogErr 
outDir=~/genomes/hg38/STARindex/ 
program=~/STAR/STAR-2.5.1a/bin/Linux_x86_64/STAR 
fastaFile=~/genomes/hg38/Homo_sapiens.GRCh38.dna.primary_assembly.fa 
gtfFile=~/genomes/hg38/Homo_sapiens.GRCh38.86.gtf 

#LSF
bsub -n 4 -R "rusage[mem=10000] span[ptile=4]" -W 11:47 -J hg38_genomeGenerate \
    -o ${outDir}/LogErr/hg38_genomeGenerate.log -e ${outDir}/LogErr/hg38_genomeGenerate.err \
    -q priority  \
    "${program} --runMode genomeGenerate --genomeDir ${outDir} \
    --genomeFastaFiles ${fastaFile} --sjdbGTFfile ${gtfFile} \
    --sjdbOverhang 99 --runThreadN 4"



# #	2. In case a Drosophila spike in was used: Create STAR index of concatenated human and Drosophila genome (generated in hg38dg6_concatenate.sh)

# module load dev/gcc-5.2.0
# mkdir -p ~/genomes/hg38dg6/STARindex/LogErr
# outDir=~/genomes/hg38dg6/STARindex/
# program=~/STAR/STAR-2.5.1a/bin/Linux_x86_64/STAR
# fastaFile=~/genomes/hg38dg6/BDGP6GRCh38.fa
# gtfFile=~/genomes/hg38dg6/BDGP6.89.GRCh38.86.gtf

# bsub -n 4 -R "rusage[mem=10000] span[ptile=4]" -W 11:47 -J hg38dg6_STARindex \
#     -o ${outDir}/LogErr/hg38dg6_STARindex.log -e ${outDir}/LogErr/hg38dg6_STARindex.err \
#     -q priority \
#     "${program} --runMode genomeGenerate --genomeDir ${outDir} \
#     --genomeFastaFiles ${fastaFile} --sjdbGTFfile ${gtfFile} \
#     --runThreadN 4"
