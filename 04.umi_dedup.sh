#!/bin/bash

HOME_PATH=/media/samba/kontogiannis_lab_pheno/data/mgi_rnaseq_02/RIP_analysis_alex/RIP_second_run/
BAM_PATH=$HOME_PATH/bam_files_bef
BAM_OUTPATH=$HOME_PATH/bam_umi_dedup

if [ ! -d $BAM_OUTPATH ]
then
    mkdir -p $BAM_OUTPATH
fi


for FILE in `ls $BAM_PATH/*.bam`
do
    SAMPLE=`basename $FILE | sed s/\.bam//`
    echo "===== Processing $SAMPLE..."
    
    umi_tools dedup \
      --output-stats $BAM_OUTPATH/$SAMPLE \
      --stdin $BAM_PATH/$SAMPLE".bam" \
      --stdout $BAM_OUTPATH/$SAMPLE".bam" \
      --unmapped-reads use \
      --log $BAM_OUTPATH/$SAMPLE"_dedup.log" \
      --paired &
done

wait

for FILE in `ls $BAM_OUTPATH/*.bam`
do
    $SAMTOOLS_COMMAND index $FILE &
done

#umi_tools dedup --output-stats test --stdin KPq10_LPS_ko1.bam --stdout KPq10_LPS_ko1_D2.bam --unmapped-reads use --paired
