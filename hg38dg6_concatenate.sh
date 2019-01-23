#!/bin/bash
#Robert Ietswaart - MIT license

# Tasks:
#	1. -prefix drosophila chromosome names with d to distinguish from human genome sequences 
#      -Concatenate human and drosophila genome sequence .fa (h: GRCh38 and d: BDGP6)
#      2. -prefix drosophila chromosome names with d (but not on first 5 lines which are header comments) to distinguish from human in annotation file (gtf) 
#      -Concatenate human and drosophila genome annotation .gtf (h: GRCh38 and d: BDGP6)
##########################################################################################


#1
mkdir -p ~/genomes/hg38dg6/
mkdir -p ~/genomes/hg38dg6/LogErr
Dir=~/genomes/hg38dg6/
cd ${Dir}
bsub -W 11:59 -J cat_hg38dg6_fasta -o ${Dir}/LogErr/cat_hg38dg6_fasta.log \
    -e ${Dir}/LogErr/cat_hg38dg6_fasta.err -q short \
    "cat ../dg6/Drosophila_melanogaster.BDGP6.dna.toplevel.fa | sed 's/^>/>d/' > BDGP6GRCh38.fa ;
    cat ../hg38/Homo_sapiens.GRCh38.dna.primary_assembly.fa  >> BDGP6GRCh38.fa"


#2.
Dir=~/genomes/hg38dg6/
cd ${Dir}
bsub -W 11:59 -J hg38dg6_gtf -o ${Dir}/LogErr/hg38dg6_gtf.log \
    -e ${Dir}/LogErr/hg38dg6_gtf.err -q short \
    "cat ../dg6/Drosophila_melanogaster.BDGP6.89.gtf  | sed 's/^/d/' > BDGP6.89.GRCh38.86.gtf ;
    sed -i '1s/^d#!genome-build/#!genome-build/' BDGP6.89.GRCh38.86.gtf  ;
    sed -i '2s/^d#!genome-version/#!genome-version/' BDGP6.89.GRCh38.86.gtf ;
    sed -i '3s/^d#!genome-date/#!genome-date/' BDGP6.89.GRCh38.86.gtf ;
    sed -i '4s/^d#!genome-build-accession/#!genome-build-accession/' BDGP6.89.GRCh38.86.gtf ;
    sed -i '5s/^d#!genebuild-last-updated/#!genebuild-last-updated/' BDGP6.89.GRCh38.86.gtf ;
    cat ../hg38/Homo_sapiens.GRCh38.86.gtf >> BDGP6.89.GRCh38.86.gtf"



