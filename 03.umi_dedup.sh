#!/bin/bash
UMI_TOOLS=$(command -v umi_tools)
SAMTOOLS_COMMAND=$(command -v samtools)
HOME_PATH=/media/samba/alexandros/analysis
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
    
    $UMI_TOOLS dedup \
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

