#!/bin/bash
#Robert Ietswaart - MIT license

# Gather sequence and annotation files from hg38 genome
#
# Tasks:
#	1. Download hg38 fasta file from ENSEMBLE (on 12/08/2016)
#	2. Download hg38 gtf file from ENSEMBLE (on 12/08/2016)
#
##########################################################################################

#	1. Download hg38 fasta file from ENSEMBLE (on 12/08/2016)

mkdir -p ~/genomes/hg38/LogErr
Dir=~/genomes/hg38/
cd ${Dir}
bsub -W 11:59 -J wget_hg38_fasta -o ${Dir}/LogErr/wget_hg38_fasta.log \
    -e ${Dir}/LogErr/wget_hg38_fasta.err -q short \
    "wget ftp://ftp.ensembl.org/pub/release-86/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"                  


#	2. Download hg38 gtf file from ENSEMBLE (on 12/08/2016)

mkdir -p ~/genomes/hg38/LogErr
Dir=~/genomes/hg38/
cd ${Dir}
bsub -W 11:59 -J wget_hg38_gtf -o ${Dir}/LogErr/wget_hg38_gtf.log \
    -e ${Dir}/LogErr/wget_hg38_gtf.err -q short  \
    "wget ftp://ftp.ensembl.org/pub/release-86/gtf/homo_sapiens/Homo_sapiens.GRCh38.86.gtf.gz"



