UMI_TOOLS=$(command -v umi_tools)
FASTQ_PATH=/media/samba/alexandros/fastq_files
FASTQ_OUTPATH=$FASTQ_PATH/fastq_files_umi-extracted

if [ ! -d $FASTQ_OUTPATH ]
then
    mkdir -p $FASTQ_OUTPATH
fi


BCPAT="NNNNNNNNNNNN"

for FILE in `ls $FASTQ_PATH/*_1.fq.gz`
do
    SAMPLE=`basename $FILE | sed s/_1\.fq\.gz//`
    echo "===== Processing $SAMPLE..."
    
    $UMI_TOOLS extract \
      --bc-pattern=$BCPAT \
      --stdin $FASTQ_PATH/$SAMPLE"_1.fq.gz" \
      --stdout $FASTQ_OUTPATH/$SAMPLE"_ext_1.fq.gz" \
      --read2-in $FASTQ_PATH/$SAMPLE"_2.fq.gz" \
      --read2-out=$FASTQ_OUTPATH/$SAMPLE"_ext_2.fq.gz" \
      --log=$FASTQ_OUTPATH/$SAMPLE".log" \
      --ignore-read-pair-suffixes &
done
