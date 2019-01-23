#!/bin/bash
#Robert Ietswaart - MIT license

# Tasks:
#	1. Download BDGP6 fasta file from ENSEMBLE (on 06/15/2017)
#	2. Download BDGP6 gtf file from ENSEMBLE (on 06/15/2017)

##########################################################################################

#	1. Download dg6 fasta file from ENSEMBLE (on 20170615)
mkdir -p ~/genomes/dg6/LogErr
Dir=~/genomes/dg6/
cd ${Dir}
bsub -W 11:59 -J wget_dg6_fasta -o ${Dir}/LogErr/wget_dg6_fasta.log \
    -e ${Dir}/LogErr/wget_dg6_fasta.err -q short \
    "wget ftp://ftp.ensembl.org/pub/release-89/fasta/drosophila_melanogaster/dna/Drosophila_melanogaster.BDGP6.dna.toplevel.fa.gz"

#	2. Download dg6 gtf file from ENSEMBLE (on 06/15/2017)
mkdir -p ~/genomes/dg6/LogErr
Dir=~/genomes/dg6/
cd ${Dir}
bsub -W 11:59 -J wget_dg6_gtf -o ${Dir}/LogErr/wget_dg6_gtf.log \
    -e ${Dir}/LogErr/wget_dg6_gtf.err -q short \
    "wget ftp://ftp.ensembl.org/pub/release-89/gtf/drosophila_melanogaster/Drosophila_melanogaster.BDGP6.89.gtf.gz"    



