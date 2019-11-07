#!/bin/bash
#RI20161212 create splicing intermediate list: code snippet received  from HML which extracts 3' of intron. 
#input: UCSC / GENCODE list with annotation of all introns in hg38.
#output SIfile ready to be used for human NET-seq alignment

#test to see what are the chromosome outputs
#awk -F  '\t' '{print $1}' ../genomes/GENCODE_V24_introns.tsv | sort | uniq 


awk -v OFS='' '{
if ($1!~"alt" && $1!~"random" && $1!~"chrUn")
   if ($6=="+")
	   print $1, "_pos_" , $3 , "\n", $1 ,"_pos_", $2;
   else if ($6=="-")
	   print $1,"_neg_", $2+1, "\n", $1, "_neg_", $3+1;
}' ../genomes/hg38/GENCODE_V24_introns.tsv | sort | uniq | sed -e 's/chr//g' > ../genomes/hg38/hg38_GENCODE_V24_ex_in_3end_siteCoordinates_1based.txt

#below only gets intron 3' end
# awk -v OFS='_' '{
# if ($1!~"alt" && $1!~"random" && $1!~"chrUn")
#    if ($6=="+")
# 	   print $1,"pos",$3;
#    else if ($6=="-")
# 	   print $1,"neg",$2+1;
# }' ../genomes/GENCODE_V24_introns.tsv | sort | uniq | sed -e 's/chr//g' >  ../genomes/hg38_GENCODE_V24_SAsiteCoordinates_1based.txt




