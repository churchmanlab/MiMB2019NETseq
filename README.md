# NETseq alignment
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4413484.svg)](https://doi.org/10.5281/zenodo.4413484)
Here we provide the custom alignment pipeline that is used to generate (human) NET-seq coverage files as described in Martell et al, Methods in Molecular Biology (accepted for publication). Considerable improvements have been made which increase the final coverage 2-3x as compared to the previous version in `https://github.com/churchmanlab/Cell2015human_NETseq`. Here, we also include code for when a Drosophila live cell spike in was used (see publication for experimental details). 

Check each shell script below to set the file paths. As indicated within the scripts uncomment the SLURM or LSF code depending on your operating system. Run shell scripts in order below after each preceding one has finished.

### Download human reference genomes for alignment with STAR
`./hg38_genome.sh`

#### Optional
In case a Drosophila spike-in was used, download Drosophila genome and concatenate both genomes.  
`./dg6_genome.sh`  
`./hg38dg6_concatenate.sh`

### Build a STAR index
`./STAR_build_index.sh`

### Extract unique molecular identifier (UMI, barcode)
This corresponds to sections 3.5.1.1-2 in publication.  
Set the field indicated in parameter file `NETseq_align_parameters.in`. 
Determine whether a linker with random hexamer (N6) or decamer (N10) UMI was used and set the file name according to instructions in script `NETseq_barcode_extraction.sh`. Then run as below.
  
`./NETseq_barcode_extraction.sh`

### Align reads using STAR
This corresponds to section 3.5.1.3 in publication.  
`./NETseq_alignment.sh`

### Filter out alignments 
This corresponds to sections 3.5.2 in publication: filter out multimapping reads, RT mispriming events, PCR duplicates and Splicing Intermediates.  
Depending on hexamer or decamer UMIs, set as per instructions in script `NETseq_remove_RTmisprimer.sh` . Then run as below.  
`./NETseq_remove_RTmisprimer.sh`  
`./NETseq_mergeBAM.sh`  
`./NETseq_remove_PCRdup_SI.sh`  

In case you need to utilize a splicing intermediate file different from `hg38_GENCODE_V24_ex_in_3end_siteCoordinates_1based.txt`: follow these instructions to generate the equivalent:
1. Go to the UCSC table browser. https://genome.ucsc.edu/cgi-bin/hgTables  
2. Select desired species and assembly  
3. Select group: Genes and Gene Prediction Tracks  
4. Select track: GENCODE V24 (or what is now latest version)  
5. Select table: knownGene  
6. Select region: genome  
7. Select output format: BED  
8. Enter output file: GENCODE_V24_introns.tsv  
9. Select file type returned: gzip compressed  
10. Hit the 'get output' button  
11. A second page of options relating to the BED file will appear.  
12. Under 'create one BED record per:'. Select 'Introns plus'  
13. Add desired flank for introns being returned, or leave as 0 to get just the introns  
14. Hit the 'get BED' option and save the file  
15. Run `./hg_SIfile_generation.sh` after adjusting filepath settings to your needs.  

### Generate Coverage files using HTseq
This corresponds to section 3.5.3 in publication.  
`./NETseq_coverage.sh`  
The resulting BedGraph files containing `stt` in their name count the read start positions, which correspond to the 3' ends of the RNA inserts, reflecting RNA Polymerase position. `cov` files count the whole RNA insert and `end` the 5' end of the RNA insert. `pos` indicates positive strand and `neg` indicates negative strand. Files with suffix `noRTbias_noPCRdup_noSI_uniq` are the resulting coverage after all the filtering steps. Coverage files without some of the filtering steps are also generated.